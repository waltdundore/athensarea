
# Hosting Collaboratively with Directus

## 🧩 Why Directus?

Directus is a free and open-source headless CMS perfect for technical and non-technical users. It offers:

- Authenticated access
- Role-based permissions
- Beautiful UI for managing content
- REST and GraphQL APIs

## ✅ How to Set Up Directus Locally with Docker

1. Add this to your `docker-compose.yml`:

```yaml
directus:
  image: directus/directus:latest
  ports:
    - "8055:8055"
  volumes:
    - ./directus-data:/directus/data
  environment:
    KEY: a_secure_random_key
    SECRET: another_secure_secret
    ADMIN_EMAIL: admin@example.com
    ADMIN_PASSWORD: admin
    DB_CLIENT: sqlite
    DB_FILENAME: /directus/data/database.db
```

2. Run:

```bash
docker-compose up -d directus
```

3. Visit http://localhost:8055 and log in with `admin@example.com` / `admin`

## 🔐 Set up Roles & Permissions

1. Go to **Settings → Roles & Permissions**
2. Create roles like:
   - Editor (can create/update)
   - Reviewer (read-only)
   - Admin (full access)

## 📝 Connect Directus Content to AthensArea

Use the Directus REST or GraphQL API to pull structured content and render it on your site. You can either:

- Build a frontend app that pulls from Directus
- Periodically sync content into the `public/` directory via a script or scheduled task

