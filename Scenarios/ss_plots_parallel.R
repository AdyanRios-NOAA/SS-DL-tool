# Run ss3.exe and SS_plots() across many Scenarios

# Load libraries
librarian::shelf(
  here,
  r4ss,
  tidyverse,
  doParallel
)

# Specify pattern
scenarios_pattern <- "^84"

# Specify ss3.exe
temp.files <- list.files(
  path = here::here("SS_LO_F_files"), 
  pattern = 'ss3.exe',
  full.names = TRUE)

# Get file names
full_names <- list.files(
  path = here::here("Scenarios"),
  pattern = scenarios_pattern,
  full.names = TRUE
)

# Get number of cores
cl <- parallel::makeCluster(parallel::detectCores()-1)

# Set up parallel
doParallel::registerDoParallel(cl)

# Run ss and SS_plots across all folders in full_names
foreach(i = seq_along(1:length(full_names))) %dopar% {
  
  # Sequence though each element of new_folder
  new_folder <- full_names[i]
  
  # Copy in excel executable
  file.copy(
    from = temp.files,
    to = new_folder,
    overwrite = TRUE
  )
  
  # Set working directory
  setwd(new_folder)
  
  # Run SS
  shell(paste("cd /d ", getwd(), " && ss3 ", sep=""))
  
  # Read in SS output
  myreplist <- r4ss::SS_output(
    dir = new_folder
  )
  
  if(dir.exists(paste0(new_folder, "/plots"))){
    unlink(
      paste0(new_folder, "/plots"),
      recursive = TRUE
    )
  }
  
  # Create SS plots
  r4ss::SS_plots(replist = myreplist)
  
  return(NULL)
}

# Turn off parallel
parallel::stopCluster(cl = cl)
doParallel::stopImplicitCluster()