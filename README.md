To operate:

- Download the latest files as a ZIP - check the "releases" page

- Extract the contents of the zip to some directory, call it `mydir`

- Set your R working directory to `mydir`, using a command like `setwd(c:/path/to/mydir)`
  - To verify, `getwd()` should output the path to `mydir`

- type `source(app.R)`

- type `shinyApp(ui = ui, server = server)`
