# 


package main

import (
	"database/sql"
	"fmt"
	"log"
	"net/url"
	"time"

	"github.com/gin-contrib/cors"
	"github.com/gin-gonic/gin"
	_ "github.com/lib/pq"
)

func main() {

	conn, _ := url.Parse(serviceURI)
	conn.RawQuery = 

	db, err := sql.Open("postgres", conn.String())

	if err != nil {
		log.Fatal(err)
	}
	defer db.Close()

	rows, err := db.Query("SELECT version()")
	if err != nil {
		panic(err)
	}

	for rows.Next() {
		var result string
		err = rows.Scan(&result)
		if err != nil {
			panic(err)
		}
		fmt.Printf("Version: %s\n", result)
	}

	router := gin.Default()

	config := cors.Config{
		AllowOrigins: []string{
			"http://localhost:5173",
			"https://localhost:5173",
		},
		AllowMethods:     []string{"GET", "POST", "PUT", "PATCH", "DELETE", "OPTIONS"},
		AllowHeaders:     []string{"Origin", "Content-Type", "Accept", "Authorization"},
		ExposeHeaders:    []string{"Content-Length"},
		AllowCredentials: true,           // Erlaubt Cookies und Auth-Header (z.B. Bearer Tokens)
		MaxAge:           12 * time.Hour, // Wie lange der Browser die CORS-Antwort cachen darf
	}

	// Middleware global für alle Routen aktivieren
	router.Use(cors.New(config))

	router.GET("/c", func(c *gin.Context) {
		fmt.Println("11111111111111111111111111111111")
		c.JSON(200, gin.H{"status": "Erfolgreich aufgerufen!"})
	})

	router.Run(":8080")

}




router := gin.Default()

	config := cors.Config{
		AllowOrigins: []string{
			"http://localhost:5173",
			"https://localhost:5173",
		},
		AllowMethods:     []string{"GET", "POST", "PUT", "PATCH", "DELETE", "OPTIONS"},
		AllowHeaders:     []string{"Origin", "Content-Type", "Accept", "Authorization"},
		ExposeHeaders:    []string{"Content-Length"},
		AllowCredentials: true,           // Erlaubt Cookies und Auth-Header (z.B. Bearer Tokens)
		MaxAge:           12 * time.Hour, // Wie lange der Browser die CORS-Antwort cachen darf
	}

	// Middleware global für alle Routen aktivieren
	router.Use(cors.New(config))

	router.GET("/", func(c *gin.Context) {
		c.JSON(200, gin.H{"status": "Erfolgreich aufgerufen!"})
	})

	router.Run(":8080")

# platform_backend

build container
docker build -t platform_backend_dev:0.0.1 -f Dockerfile.dev .

start container
docker run -d -p 8080:8080 --name platform_backend_dev --env-file .env platform_backend_dev:0.0.1