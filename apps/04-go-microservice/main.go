// Command inventory serves warehouse stock levels for the Northwind demo stack.
package main

import (
	"encoding/json"
	"log"
	"net/http"
	"os"
	"sync"
)

type item struct {
	SKU      string `json:"sku"`
	OnHand   int    `json:"on_hand"`
	Reserved int    `json:"reserved"`
}

var (
	mu    sync.RWMutex
	stock = map[string]item{
		"NW-COFFEE-12OZ": {SKU: "NW-COFFEE-12OZ", OnHand: 412, Reserved: 36},
		"NW-TEA-TIN":     {SKU: "NW-TEA-TIN", OnHand: 88, Reserved: 4},
	}
)

func writeJSON(w http.ResponseWriter, status int, v any) {
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(status)
	_ = json.NewEncoder(w).Encode(v)
}

func main() {
	mux := http.NewServeMux()

	mux.HandleFunc("GET /healthz", func(w http.ResponseWriter, r *http.Request) {
		writeJSON(w, http.StatusOK, map[string]string{"status": "ok", "service": "inventory"})
	})

	mux.HandleFunc("GET /api/stock", func(w http.ResponseWriter, r *http.Request) {
		mu.RLock()
		defer mu.RUnlock()

		items := make([]item, 0, len(stock))
		for _, it := range stock {
			items = append(items, it)
		}
		writeJSON(w, http.StatusOK, map[string]any{"items": items})
	})

	mux.HandleFunc("GET /api/stock/{sku}", func(w http.ResponseWriter, r *http.Request) {
		mu.RLock()
		defer mu.RUnlock()

		it, ok := stock[r.PathValue("sku")]
		if !ok {
			writeJSON(w, http.StatusNotFound, map[string]string{"error": "unknown sku"})
			return
		}
		writeJSON(w, http.StatusOK, it)
	})

	addr := ":" + orDefault(os.Getenv("PORT"), "8080")
	log.Printf("inventory listening on %s", addr)
	if err := http.ListenAndServe(addr, mux); err != nil {
		log.Fatal(err)
	}
}

func orDefault(value, fallback string) string {
	if value == "" {
		return fallback
	}
	return value
}
