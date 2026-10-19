//! Telemetry ingest for the Northwind demo stack.
//!
//! Dependency-free on purpose so the demo image builds without a crates.io
//! round trip.

use std::env;
use std::io::{BufRead, BufReader, Write};
use std::net::{TcpListener, TcpStream};

fn respond(stream: &mut TcpStream, status: &str, body: &str) -> std::io::Result<()> {
    write!(
        stream,
        "HTTP/1.1 {status}\r\nContent-Type: application/json\r\nContent-Length: {}\r\nConnection: close\r\n\r\n{body}",
        body.len()
    )
}

fn handle(mut stream: TcpStream) -> std::io::Result<()> {
    let mut reader = BufReader::new(stream.try_clone()?);
    let mut request_line = String::new();
    reader.read_line(&mut request_line)?;

    let path = request_line.split_whitespace().nth(1).unwrap_or("/");

    match path {
        "/healthz" => respond(
            &mut stream,
            "200 OK",
            r#"{"status":"ok","service":"telemetry"}"#,
        ),
        "/api/metrics" => respond(
            &mut stream,
            "200 OK",
            r#"{"ingested":10423,"dropped":0,"window":"5m"}"#,
        ),
        _ => respond(&mut stream, "404 Not Found", r#"{"error":"not found"}"#),
    }
}

fn main() -> std::io::Result<()> {
    let port = env::var("PORT").unwrap_or_else(|_| "9000".to_string());
    let listener = TcpListener::bind(format!("0.0.0.0:{port}"))?;
    println!("telemetry listening on :{port}");

    for stream in listener.incoming() {
        match stream {
            Ok(stream) => {
                if let Err(err) = handle(stream) {
                    eprintln!("connection error: {err}");
                }
            }
            Err(err) => eprintln!("accept error: {err}"),
        }
    }

    Ok(())
}
