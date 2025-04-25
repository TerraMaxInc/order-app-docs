# Azure Overview


## Summary

Azure is a cloud platform owned by Microsoft that offers a variety of
online resources. TerraMax has a single Azure account which, thought not
part of the TerraMax Microsoft 365 account, uses the same **tenant id**.
This means that both accounts are part of the same organization, share
access to user identities and security settings, and are both managed
through **Microsoft Entra**.

This project uses Azure to host several components in a secure and
centralized way, allowing them to share the same security
infrastructure. These components include:

- **Ordering App**: a user-facing web app that users can directly
  interact with to submit and manage Deals in HubSpot.
  - Hosted in **Azure Static Web Apps**
  - Written in **React + Typescript**
  - Uses **Microsoft Entra ID authentication** via MSAL, allowing only
    TerraMax users to log in
- **HubSpot Service**: a backend API that connects the Ordering App to
  both an internal product database, and HubSpot’s records of customers
  and sales.
  - Hosted in **Azure Functions**
  - Written in **Typescript**
  - Uses **Microsoft Entra ID** to validate incoming requests and
    restrict access to approved applications
- **TerraMax Data**: a SQL database that holds the masterlist of product
  information, and a log of transactions that have passed through the
  server app.
  - Hosted in **Azure SQL database**
  - Accessed only through the server app, not directly by the client

------------------------------------------------------------------------

## Azure Portal

These resources can be viewed and managed through the **Azure Portal**.
When logged in to the home page, you should see a row of icons of Azure
Services, like *Static Web Apps* and *Azure Functions*, as well as the
identity manager *Entra*. Below that you should see a list of all
current resources.

![Azure Portal Home Screen](../..\images/azure-portal-home.jpg)

Core components of this project include:

- `terramax-ordering-app`
- `terramax-hubspot-service`
- `terramax-data`

Other relevant resources:

- `terramax-hubspot-service-app-insights`
- `terramax-db-server`
- `testresourcegroup`
- `ordering-app_group`
