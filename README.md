# Distributed Logging System

A complete distributed logging infrastructure that collects, processes, and visualizes logs from microservices using Kafka, Elasticsearch, and Grafana.

## Project Overview

This project implements an end-to-end logging pipeline for distributed systems. It captures logs from services, streams them through Kafka, processes them with Logstash, stores them in Elasticsearch, and provides real-time visualization through  Grafana.

### Key Features

- **Event Streaming**: Apache Kafka for reliable log ingestion and processing
- **Log Processing**: Logstash pipeline for filtering and enriching logs
- **Full-Text Search**: Elasticsearch for powerful log searching and analysis
- **Visualization**: Kibana for log exploration and Grafana for monitoring
- **Sample Log Producer**: Python service that generates realistic log events
- **Containerized**: All services run in Docker containers for easy setup

## Architecture

```
Log Producer → Kafka → Logstash → Elasticsearch ↔ Kibana & Grafana
```

- **Log Producer**: Python application that generates sample logs
- **Kafka**: Message broker for streaming logs
- **Logstash**: Data processing pipeline that ingests from Kafka and outputs to Elasticsearch
- **Elasticsearch**: Search and analytics engine for log storage
- **Kibana**: Web UI for searching and visualizing logs
- **Grafana**: Monitoring and analytics platform

## Prerequisites

- Docker and Docker Compose installed
- Python 3.7+ (for local development without Docker)
- At least 2GB of free disk space
- Ports 9092, 9200, 5601, 5044, and 3000 available

## Quick Start

### 1. Start All Services with Docker Compose

```bash
docker-compose up -d
```

This will start all services in the background:
- Kafka (port 9092)
- Elasticsearch (port 9200)
- Kibana (port 5601)
- Logstash
- Log Producer
- Grafana (port 3000)

### 2. Verify Services Are Running

```bash
docker-compose ps
```

You should see all containers with status "Up".

### 3. Access the Web Interfaces

Once services are running, open the following in your browser:

- **Kibana**: http://localhost:5601
  - View and search logs collected from Kafka
  - Create visualizations and dashboards

- **Grafana**: http://localhost:3000
  - Username: `admin`
  - Password: `admin`
  - Add Elasticsearch as a data source to create additional dashboards

## Setup Instructions

### Local Development Setup (Without Docker)

If you prefer to run services locally:

1. **Create and activate a Python virtual environment**:
   ```bash
   python -m venv env
   env\Scripts\activate  # On Windows
   # source env/bin/activate  # On macOS/Linux
   ```

2. **Install dependencies**:
   ```bash
   pip install -r services/log-producer/requirements.txt
   ```

3. **Start Kafka, Elasticsearch, Kibana, and Logstash** (using Docker):
   ```bash
   docker-compose up -d kafka elasticsearch kibana logstash
   ```

4. **Run the log producer**:
   ```bash
   python services/log-producer/app.py
   ```

### Using Terraform for Cloud Deployment

Infrastructure as Code files are included for cloud deployment:

```bash
cd terraform

# Initialize Terraform
terraform init

# Plan the deployment
terraform plan -var-file=terraform.tfvars

# Apply the configuration
terraform apply -var-file=terraform.tfvars
```

Update `terraform.tfvars` with your cloud provider credentials and desired configuration.

## Services and Ports

| Service | Port | Purpose |
|---------|------|---------|
| Kafka | 9092 | Message broker for log streaming |
| Elasticsearch | 9200 | Log storage and search engine |
| Kibana | 5601 | Log visualization and exploration |
| Logstash | 5044 | Log pipeline processing |
| Grafana | 3000 | Monitoring and analytics dashboards |

## Log Producer

The log producer service (`services/log-producer/app.py`) generates sample logs with the following structure:

```json
{
  "timestamp": "2026-02-16T12:34:56",
  "service": "orders",
  "level": "INFO|WARN|ERROR",
  "message": "Log message describing the event",
  "order_id": "unique-identifier"
}
```

Logs are produced every 2 seconds to the `logs` Kafka topic.

## Configuration Files

### Logstash Pipeline

The Logstash configuration (`logstash/pipeline/logstash.conf`) defines:
- **Input**: Consumes messages from the `logs` Kafka topic
- **Filter**: Parses timestamps and enriches events
- **Output**: Sends logs to Elasticsearch with daily indices

### Kafka Configuration

Configured in `docker-compose.yml` with:
- KRaft mode (no Zookeeper required)
- Auto topic creation enabled
- Single node mode for local development

## Viewing and Analyzing Logs

### In Kibana

1. Navigate to http://localhost:5601
2. Click **"Discover"** in the sidebar
3. Select the `service-logs-*` index pattern
4. Logs appear with full-text search capabilities
5. Filter by log level, timestamp, service, or order ID
6. Create custom visualizations and dashboards

### Log Format

Logs are indexed daily with the pattern: `service-logs-YYYY.MM.DD`

## Cleaning Up

To stop all services:

```bash
docker-compose down
```

To remove containers and volumes (including stored logs):

```bash
docker-compose down -v
```

## Troubleshooting

### Services Won't Start

- Check port availability: `netstat -an | findstr LISTEN` (Windows)
- Ensure at least 2GB free disk space
- Check Docker Compose logs: `docker-compose logs`

### No Logs Appearing in Kibana

1. Verify log producer is running: `docker-compose logs log-producer`
2. Check Kafka has the `logs` topic: `docker exec kafka kafka-topics.sh --bootstrap-server kafka:9092 --list`
3. Verify Elasticsearch is healthy: `curl http://localhost:9200/_health`
4. Check Logstash logs: `docker-compose logs logstash`

### Elasticsearch Out of Memory

Increase memory limits in `docker-compose.yml`:
```yaml
elasticsearch:
  environment:
    - ES_JAVA_OPTS=-Xms1g -Xmx1g
```

## Project Structure

```
Distributed-Logging/
├── docker-compose.yml       # Docker Compose configuration
├── logstash/
│   └── pipeline/
│       └── logstash.conf    # Logstash pipeline configuration
├── services/
│   └── log-producer/
│       ├── app.py           # Python log producer service
│       ├── Dockerfile       # Docker image for log producer
│       └── requirements.txt  # Python dependencies
├── terraform/               # Infrastructure as Code files
└── README.md               # This file
```

## Requirements

### Python Dependencies
- kafka-python: Apache Kafka client for Python

### Docker Images
- apache/kafka:3.7.1
- docker.elastic.co/elasticsearch/elasticsearch:7.17.16
- docker.elastic.co/kibana/kibana:7.17.16
- docker.elastic.co/logstash/logstash:7.17.16
- grafana/grafana:10.2.3

## License

See the LICENSE file for licensing information.

## Contributing

Contributions are welcome! Please feel free to submit pull requests or open issues for bugs and feature requests.

## Next Steps

1. Start the services: `docker-compose up -d`
2. Wait 30 seconds for Elasticsearch to be ready
3. Open Kibana at http://localhost:5601
4. Start exploring collected logs!
