"""Settlement worker: drains the settlement queue and posts to the ledger."""

from __future__ import annotations

import json
import logging
import os
import signal
import sys
import time

import redis

LOG = logging.getLogger("settlement-worker")

QUEUE = os.environ.get("SETTLEMENT_QUEUE", "northwind:settlements")
REDIS_URL = os.environ.get("REDIS_URL", "redis://redis:6379/0")
POLL_TIMEOUT = int(os.environ.get("POLL_TIMEOUT_SECONDS", "5"))

_running = True


def _stop(signum: int, _frame: object) -> None:
    global _running
    LOG.info("received signal %s, draining and shutting down", signum)
    _running = False


def settle(job: dict) -> dict:
    """Net the debits against the credits for a single settlement batch."""
    debits = sum(float(line["amount"]) for line in job["lines"] if line["side"] == "debit")
    credits = sum(float(line["amount"]) for line in job["lines"] if line["side"] == "credit")

    return {
        "batch_id": job["batch_id"],
        "net": round(credits - debits, 2),
        "line_count": len(job["lines"]),
        "settled_at": time.time(),
    }


def main() -> int:
    logging.basicConfig(level=logging.INFO, format="%(asctime)s %(levelname)s %(message)s")
    signal.signal(signal.SIGTERM, _stop)
    signal.signal(signal.SIGINT, _stop)

    client = redis.Redis.from_url(REDIS_URL, decode_responses=True)
    LOG.info("worker online, polling %s", QUEUE)

    while _running:
        item = client.blpop(QUEUE, timeout=POLL_TIMEOUT)
        if item is None:
            continue

        _, raw = item
        try:
            result = settle(json.loads(raw))
        except (ValueError, KeyError) as err:
            LOG.error("dropping malformed job: %s", err)
            client.rpush(f"{QUEUE}:dead", raw)
            continue

        client.rpush(f"{QUEUE}:settled", json.dumps(result))
        LOG.info("settled batch %s net=%s", result["batch_id"], result["net"])

    LOG.info("worker stopped")
    return 0


if __name__ == "__main__":
    sys.exit(main())
