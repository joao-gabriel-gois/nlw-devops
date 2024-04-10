resource "digitalocean_database_cluster" "postgres_db_cluster" {
  name       = "nlw-unite"
  engine     = "pg"
  version    = "16"
  size       = "db-s-1vcpu-1gb"
  region     = "nyc1"
  node_count = 1
}

resource "digitalocean_database_db" "postgres_db" {
  cluster_id = digitalocean_database_cluster.postgres_db_cluster.id
  name       = "nlw-unite"
  depends_on = [
    digitalocean_database_cluster.postgres_db_cluster
  ]
}
