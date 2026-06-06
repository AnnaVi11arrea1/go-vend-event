
## goVend
<br>

An app that helps connects vendors to events! Search for events and find out how/where to apply. 

### A personal note
As an artist and vendor for over 7 years, I have traveled the country selling my art at music events, festivals, fairs, cons, and farmers markets. I have found it a huge challenge organizing my events, keeping track of pertinent data, and related complications. Event vendors need an app that they can consolidate all of there information in. This is not another eventbright app. This is for event vendors to find and organize their events, and for event promotors to share there events. Sure, there are other management apps out there. But being a vendor is a very specific job, and anyone that has done events with multiple coordinators knows that every event has different requirements and specifications. It will be a different experience depending on the event and type of vendor you are. Are you a craft vendor? Are you doing an art installment? Or is your food truck looking to share their treats at the coolest local food fest? This app aims to consolidate users specific needs in one unified location. :)


<br>

![Screenshot 2024-12-12 003217](https://github.com/user-attachments/assets/3946bf7e-dc70-4eaf-9653-8e407904002d)

![Screenshot 2024-12-12 003217](https://github.com/user-attachments/assets/b06658b8-19a0-4f9e-a3cb-86dc1ed0e23a)


<hr>

## Install

1. Clone the repository:
`git clone https://github.com/yourusername/yourproject.git`

2. Navigate to the project directory:
`cd yourproject`

3. Install the required gems:
`bundle install`

4. Set up the database:
`rails db:create`
`rails db:migrate`

5. Run rake tasks so you have something to look at:
`rake csv:admin`
`rake csv:users`
`rake csv:events`

![Screenshot 2024-11-22 221850](https://github.com/user-attachments/assets/63b910a5-3963-4359-bee0-ca37d4d15745)

7. Start server
run `rails s` in the terminal.

<hr>

## Usage 

1. Open your browser and navigate to http://localhost:3000
Follow the on-screen instructions to use the application

2. Create a user account so you can interact with the features!

<hr>

## Config

1. You will need to setup a google maps API and add it to your environment variables.
   
2. You will need to setup an IAM account and a S3 bucket for photo storage and include those credentials as well.

## AI Chat Defaults (Nano Friendly)

Out of the box, AI chat now defaults to a Jetson-friendly profile:

1. `OLLAMA_MODEL=llama3.2:1b`
2. `OLLAMA_NUM_CTX=1024`
3. `OLLAMA_NUM_PREDICT=384`
4. `OLLAMA_TEMPERATURE=0.3`

To prepare a self-hosted Linux/Jetson host:

```bash
ollama pull llama3.2:1b
```

The deploy env template in `deploy/systemd/govend.env.example` already includes these settings.

Validate AI runtime and Nano-safety on host:

```bash
bundle exec rake ai:nano_check
```

Automatic Nano bootstrap at deploy:

1. `./bin/post-deploy.sh` now runs `./bin/nano-ai-bootstrap.sh`
2. On Jetson hosts, it automatically:
	- Applies Nano-safe Ollama env values
	- Tries to start Ollama service (if available)
	- Pulls the configured lightweight model
	- Runs `bundle exec rake ai:nano_check`
3. On non-Jetson hosts, it safely no-ops.

## Scraper Scheduling (Render + Self-Hosted)

The scraper is configured to run in two phases:

1. Once at deployment via `scraper:deploy`
2. Monthly on the 1st day via `scraper:monthly`

### Portable deploy hook (any host)

Run this after each successful deploy:

```bash
./bin/post-deploy.sh
```

This script currently runs:

```bash
bundle exec rake scraper:deploy
```

### Self-hosted Linux / Jetson (cron)

Preferred for self-hosted Linux is systemd timer units (more reliable than user crontab).

### Self-hosted Linux / Jetson (systemd, recommended)

This repo includes ready-to-use units:

1. `deploy/systemd/govend-scraper-monthly.service`
2. `deploy/systemd/govend-scraper-monthly.timer`
3. `deploy/systemd/govend.env.example`

Install on host:

```bash
sudo cp deploy/systemd/govend-scraper-monthly.service /etc/systemd/system/
sudo cp deploy/systemd/govend-scraper-monthly.timer /etc/systemd/system/
sudo cp deploy/systemd/govend.env.example /etc/default/govend
```

Edit unit paths/user/group for your machine:

1. Update `User`, `Group`, `WorkingDirectory`, and log paths in `/etc/systemd/system/govend-scraper-monthly.service`
2. Update secrets/env vars in `/etc/default/govend`

Enable and start:

```bash
sudo systemctl daemon-reload
sudo systemctl enable --now govend-scraper-monthly.timer
```

Verify status and next run:

```bash
systemctl status govend-scraper-monthly.timer
systemctl list-timers govend-scraper-monthly.timer
```

Run once manually for smoke test:

```bash
sudo systemctl start govend-scraper-monthly.service
```

### Self-hosted Linux / Jetson (cron fallback)

From the app directory, add a cron entry for the app user:

```bash
crontab -e
```

Add:

```cron
0 3 1 * * cd /workspaces/go-vend-event && /usr/bin/env bash -lc 'bundle exec rake scraper:monthly RAILS_ENV=production' >> log/cron_log.log 2>&1
```

Notes:

1. Replace `/workspaces/go-vend-event` with your actual deploy path on the Jetson.
2. Make sure your production env vars are available to cron (or sourced in the command).

### Render

Render is already wired in this repo:

1. Deploy-time run in `bin/render-build.sh` via `./bin/post-deploy.sh`
2. Monthly run via cron service in `render.yaml`

### Optional: Whenever-based cron installation

If you use `whenever` on your host, this repo already defines monthly schedule in `config/schedule.rb`.
Install/update cron with:

```bash
bundle exec whenever --update-crontab
```

## ERD

**Please note that this is the original ERD, and that it has since been modified greatly. This is to aid in providing a broad idea for newcomers.

![Screenshot 2024-12-09 145151](https://github.com/user-attachments/assets/31316f7c-c78e-49c8-b8dc-a7b80e337ddc)

<hr>

## Contribute

- See CONTRIBUTE.md :)
  
<hr>

## API

Google maps: <a href="https://mapsplatform.google.com/?utm_source=google&utm_medium=cpc&utm_campaign=google_maps_brand_us_1&gad_source=1&gclid=Cj0KCQiAx9q6BhCDARIsACwUxu5pCo2TeSBr7uZv1pddBhuudpFeQo5A2Z-Mi7afs3LlJ8NEe6lrGGwaAvulEALw_wcB&gclsrc=aw.ds">Google Maps API</a>
Amazon: <a href="https://aws.amazon.com/iam/?gclid=Cj0KCQiAx9q6BhCDARIsACwUxu69lUF2r85cryrvzNg0WFRbYyKEZnlcousLmgrIc3STjyVvimpcbKMaAiurEALw_wcB&trk=da94b437-337f-4ee7-81b4-5dcf158370ab&sc_channel=ps&ef_id=Cj0KCQiAx9q6BhCDARIsACwUxu69lUF2r85cryrvzNg0WFRbYyKEZnlcousLmgrIc3STjyVvimpcbKMaAiurEALw_wcB:G:s&s_kwcid=AL!4422!3!651737511581!e!!g!!amazon%20iam%20console!19845796027!146736269229">AWS IAM</a>

<hr>

## Contact & Troubleshooting

If you stumble into an unresolvable problem, create an issue and tag me, or send me a message! 
Anna Villarreal [stayfluorescent@gmail.com](mailto:stayfluorescence@gmail.com)
