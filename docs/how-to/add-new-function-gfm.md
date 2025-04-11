

# Adding a New Function

<!-- To regenerate the Markdown version of this file, enter in the terminal:
    quarto render docs/how-to/add-new-function.qmd 
-->

This guide walks through all the necessary steps to add a new Azure
Function to the hubspot-service backend and make it accessible to the
client app.

This is NOT a guide to writing Azure Functions, but to integrating them
into the existing app.

------------------------------------------------------------------------

## 1. Create Function in ‘hubspot-service’ Codebase

    - The new `.ts` file should be in the `functions` directory.

## 2. Deploy to Live Azure Functions App

- Make sure you are logged in to theTerraMax Azure account
- In VSCode, select `Azure Functions: Deploy to Function App...`
- Select `terramax-hubspot-service` as the function app to deploy to. A
  pop-up will ask you if you want to deploy; click the `Deploy` button.
- The terminal will display information about the deployment execution,
  and tell you if it was successful.

## 3.
