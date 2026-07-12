<div align="center">

# 🎪 goVend

**The app that connects vendors to events.**

Search for events, discover how and where to apply, and keep all your vending logistics
organized in one place — built by a vendor, for vendors.

[![Ruby on Rails](https://img.shields.io/badge/Ruby_on_Rails-CC0000?logo=rubyonrails&logoColor=white)](https://rubyonrails.org/)
[![Ruby](https://img.shields.io/badge/Ruby-3.1.2-CC342D?logo=ruby&logoColor=white)](https://www.ruby-lang.org/)
[![PostgreSQL](https://img.shields.io/badge/PostgreSQL-4169E1?logo=postgresql&logoColor=white)](https://www.postgresql.org/)
[![Docker](https://img.shields.io/badge/Docker-2496ED?logo=docker&logoColor=white)](https://www.docker.com/)
[![Live Site](https://img.shields.io/badge/Live-govend.ing-brightgreen)](https://www.govend.ing/)

</div>

---

## ✨ Overview

goVend helps event vendors **find events, apply to them, and stay organized** — and helps event
promoters **share their events** with the right vendors.

This isn't another Eventbrite. It's purpose-built for the specific, messy reality of vending:
every event has different requirements, different coordinators, and different specs.

### 💬 A personal note

> As an artist and vendor for over 7 years, I've traveled the country selling my art at music
> events, festivals, fairs, cons, and farmers markets. Organizing events, tracking pertinent
> data, and juggling each coordinator's requirements is a genuine challenge. Event vendors need
> one place to consolidate all their information — whether you're a craft vendor, running an art
> installation, or a food truck looking to share treats at the coolest local food fest. goVend
> aims to bring those needs into one unified home. 🙂

---

## 🖼️ Screenshots

<div align="center">

![goVend screenshot](https://github.com/user-attachments/assets/3946bf7e-dc70-4eaf-9653-8e407904002d)

![goVend screenshot](https://github.com/user-attachments/assets/b06658b8-19a0-4f9e-a3cb-86dc1ed0e23a)

</div>

---

## 🛠️ Tech Stack

- **Ruby on Rails** (Ruby 3.1.2) — full-stack web framework
- **PostgreSQL** — relational database
- **Docker** — containerized dev environment (`docker-compose.yml`)
- **RSpec** — test suite
- **Google Maps API** — location & mapping
- **AWS S3 + IAM** — photo storage
- **Render** — hosting (`render.yaml`)

---

## 🚀 Installation

```bash
# 1. Clone the repository
git clone https://github.com/annavi11arrea1/go-vend-event.git
cd go-vend-event

# 2. Install dependencies
bundle install

# 3. Set up the database
rails db:create
rails db:migrate

# 4. Seed sample data so you have something to look at
rake csv:admin
rake csv:users
rake csv:events

# 5. Start the server
rails s
```

Then open **http://localhost:3000** and create a user account to explore the features.

<div align="center">

![Seed data screenshot](https://github.com/user-attachments/assets/63b910a5-3963-4359-bee0-ca37d4d15745)

</div>

---

## ⚙️ Configuration

You'll need to provide the following credentials via environment variables:

1. **Google Maps API key** — for location and mapping features
2. **AWS IAM account + S3 bucket** — for photo storage

| Service | Link |
|---------|------|
| Google Maps Platform | [mapsplatform.google.com](https://mapsplatform.google.com/) |
| AWS IAM | [aws.amazon.com/iam](https://aws.amazon.com/iam/) |

---

## 🗺️ ERD

> **Note:** This is the *original* ERD and has since been modified significantly. It's included
> to give newcomers a broad conceptual overview.

<div align="center">

![goVend ERD](https://github.com/user-attachments/assets/31316f7c-c78e-49c8-b8dc-a7b80e337ddc)

</div>

---

## 🤝 Contributing

Contributions are welcome — see [`CONTRIBUTE.md`](CONTRIBUTE.md) for guidelines.

---

## 📬 Contact & Troubleshooting

Hit an unresolvable problem? Open an issue and tag me, or reach out directly:

**Anna Villarreal** — [stayfluorescent@gmail.com](mailto:stayfluorescent@gmail.com)

<div align="center">

🌐 Live at [govend.ing](https://www.govend.ing/)

</div>
