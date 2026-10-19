package dev.chainguard.ledger;

import java.math.BigDecimal;
import java.util.List;
import java.util.Map;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@SpringBootApplication
public class LedgerApplication {

    public static void main(String[] args) {
        SpringApplication.run(LedgerApplication.class, args);
    }

    public record Entry(String account, String currency, BigDecimal balance) {
    }

    @RestController
    @RequestMapping("/api/ledger")
    static class LedgerController {

        private static final List<Entry> ENTRIES = List.of(
                new Entry("northwind-freight", "USD", new BigDecimal("18240.55")),
                new Entry("northwind-retail", "USD", new BigDecimal("-920.00")));

        @GetMapping("/entries")
        Map<String, Object> entries() {
            return Map.of("entries", ENTRIES, "count", ENTRIES.size());
        }
    }
}
