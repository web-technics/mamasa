# Mama Sa Website

Static website for Mama Sa Hotel & Restaurant in Kampot, Cambodia.

## Pages

- `index.html` - homepage for the hotel and retreat
- `booking.html` - direct room booking page
- `restaurant.html` - rooftop restaurant page
- `offers.html` - Tourist.com promotional landing page

## Assets

- `images/` contains room photos, restaurant photos, menu images, logo files, and social share images
- `generate-og-images.ps1` generates the Open Graph preview images used for social sharing

## SEO And Social Sharing

- canonical URLs are set per page
- Open Graph and Twitter card tags are configured for the main pages
- dedicated share images are available for:
  - `images/og-home.png`
  - `images/og-booking.png`
  - `images/og-restaurant.png`
  - `images/og-offers.png`

## Local Preview

Open the HTML files directly in a browser, or serve the folder with any static web server.

Example with Python:

```bash
python -m http.server 8000
```

Then open `http://localhost:8000`.

## Deployment Note

This repository is hosted on GitHub, but the live domain `mamasa.site` is not currently auto-deployed from GitHub by this repo alone. If the live site does not update after a push, the hosting server likely needs a separate deploy step or sync.

## Repository

- GitHub: `https://github.com/web-technics/mamasa.git`