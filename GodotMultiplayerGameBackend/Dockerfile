FROM golang:alpine

WORKDIR /app

# Install Air for hot reloading
RUN go install github.com/air-verse/air@latest

COPY go.mod go.sum ./
RUN go mod download

COPY . .

# Default command uses Air
CMD ["air", "-c", ".air.toml"]
