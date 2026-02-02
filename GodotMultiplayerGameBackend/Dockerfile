FROM golang:alpine

WORKDIR /app

# Install Air for hot reloading
RUN go install github.com/air-verse/air@latest

COPY go.mod go.sum ./
RUN go mod download

COPY . .
RUN go build -o main ./cmd/api/main.go

# Default command uses Air
CMD ["air", "-c", ".air.toml"]
