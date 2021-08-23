# StoryBooks

> Create public and private stories from your life

This app uses Node.js/Express/MongoDB with Google OAuth for authentication

This app also uses Terraform to provision both a staging and a production environment to deploy the app.

### Staging
https://user-images.githubusercontent.com/26441727/130375891-4799df14-641b-4186-be7e-1bd2fb00f4f7.png


### Production
https://user-images.githubusercontent.com/26441727/130375892-4f4a742d-0439-4e8e-a362-d701eaa8245a.png

Deployed to Google Cloud Compute Engine, Database hosted on MongoDB Atlas, Cloudflare for DNS

## Usage

Add your mongoDB URI and Google OAuth credentials to the config.env file

```
# Install dependencies
npm install

# Run in development
npm run dev

# Run in production
npm start
```
