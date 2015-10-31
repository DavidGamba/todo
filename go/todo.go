package main

import (
	"database/sql"
	"fmt"
	_ "github.com/mattn/go-sqlite3"
	"log"
	"os"
)

const dbName string = "todo.db"

func createDB(dbFileName string) (*sql.DB, error) {
	db, err := sql.Open("sqlite3", dbFileName)
	if err != nil {
		log.Fatal(err)
		return nil, err
	}

	sqlStmt := `create table tasks (
		id integer not null primary key,
		priority integer not null,
		subject text not null,
		file text,
		attachments text
	);`

	_, err = db.Exec(sqlStmt)
	if err != nil {
		log.Printf("%q: %s\n", err, sqlStmt)
		return nil, err
	}

	return db, nil
}

func main() {
	fmt.Println("hello")

	var db *sql.DB
	dbFileName := "." + string(os.PathSeparator) + dbName
	if _, err := os.Stat(dbFileName); os.IsNotExist(err) {
		log.Println("creating DB")
		db, err = createDB(dbFileName)
	} else {
		log.Println("opening DB")
		db, err = sql.Open("sqlite3", dbFileName)
		if err != nil {
			log.Fatal(err)
		}
	}
	defer db.Close()

	_, err := db.Exec("insert into tasks(priority, subject) values(3, 'finish program'), (1, 'low'), (5, 'high')")
	if err != nil {
		log.Fatal(err)
	}

	rows, err := db.Query("select id, priority, subject from tasks")
	if err != nil {
		log.Fatal(err)
	}
	defer rows.Close()
	for rows.Next() {
		var id int
		var priority int
		var subject string
		rows.Scan(&id, &priority, &subject)
		fmt.Println(id, priority, subject)
	}

}
