# estimate_nHealthCareFacs
Estimating the number of health care facilities in sub-Saharan Africa.



# Shiny Application README

## Project Overview

This repository contains an R Shiny application that provides interactive visualizations of the number of health facilities in a country, and the proportion of the facilities which are hospitals. The application is designed to be user-friendly and highly interactive, allowing users to explore and compare two different predictions for the number of health facilities in a country.

---

## Features

- **Feature 1**: The data, line of best fit (log-log linear regression (MODEL 1)). 
- **Feature 2**: Select countries to see predictions from MODEL 1 and MODEL 2. 
- **Feature 3**: Plots for the error analysis of the models for the selected countries.
- **Feature 4**: The proportion of the facilities which are hospitals. It seems that some countries, like Sudan, are lacking data on primary and secondary level facilities.
---

## Requirements

To run the app, ensure you have the following installed:

1. **R**: Version 4.0.0 or higher.
2. **R Packages**:
   - shiny
   - ggplot2
   - dplyr
   - [Other dependencies based on the app]

You can install all required packages by running the following in your R console:

```R
install.packages(c("shiny", "ggplot2", "dplyr"))
```

---

## How to Run

1. Clone or download this repository to your local machine.
2. Open the `app.R` file in RStudio or your preferred R IDE.
3. Run the following command in your R console:

   ```R
   shiny::runApp("path/to/app.R")
   ```

   Replace `"path/to/app.R"` with the correct path to the `app.R` file.

4. The app will launch in your default web browser.

---

## File Structure

- `app.R`: The main script containing the Shiny app's code.
- [Any other relevant files or directories]

---

## Usage

1. **Step 1**: [Explain how to start using the app, e.g., "Upload a dataset."]
2. **Step 2**: [Explain interactions or inputs users can make, e.g., "Select a variable to analyze."]
3. **Step 3**: [Describe outputs or results.]

---

## Support

If you encounter any issues or have questions about the app, feel free to [include a way to reach out, e.g., "submit an issue in this repository" or "email me at example@example.com"].

---

## License

[Specify license details, e.g., "This project is licensed under the MIT License. See the LICENSE file for details."]

