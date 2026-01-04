# syntax=docker/dockerfile:1

FROM golang:1.24.5-alpine AS build
WORKDIR /src

COPY go.mod go.sum ./
RUN go mod download

COPY . .
RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -o app .

FROM alpine:3.20
WORKDIR /app

COPY --from=build /src/app ./app
COPY tracker.db ./tracker.db

RUN adduser -D appuser \
    && chown -R appuser:appuser /app \
    && chmod 664 /app/tracker.db

USER appuser

CMD ["./app"]
