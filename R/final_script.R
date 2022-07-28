# Eric and Ian: A touch of R in Robotics

## Please see the folder `torr` for detailed explanations

# speech to text ----------------------------------------------------------

#Load the packages
library(here)
library(httr)
library(jsonlite)
library(stringr)
library(audio)
library(serial)
library(dplyr)
library(purrr)
library(tibble)

set.audio.driver(NULL)
rec_time <- 5 # Set the time duration of the recording
x_cont<-rep(NA_real_, 44100 * rec_time) #Defining number of samples recorded
inst <-record(x_cont, 44100, 1) #audio instance with sample rate = 44100 and number of channels = 1
wait(6)
rec <- inst$data # get the result from the audio instance object

save.wave(rec,"sample4.wav")

.rs.restartR() # Temporary fix to clear the audio instance object
#wait(6)
#play(rec)


#Transcription_converting speech recorded to test
#require(httr)
#require(jsonlite)

headers = c(
  `Ocp-Apim-Subscription-Key` = 'be4e729c99e84c298a78e56049d06643',
  `Content-Type` = 'audio/wav'
)

params = list(
  `language` = 'en-US'
)

data = httr::upload_file("sample4.wav")  
txt_input <- httr::POST(url = 'https://eastus.stt.speech.microsoft.com/speech/recognition/conversation/cognitiveservices/v1',
                        httr::add_headers(.headers=headers),
                        query = params, body = data) %>% 
  # Extract content from a request
  content(as = "text") %>% 
  # Convert JSON to R list then tibble
  jsonlite::fromJSON() %>% as_tibble() %>% 
  # Extract transcription
  pull(DisplayText)

#View(txt_output)



#Validate input to catch errors in transcription
library(assert)
assert(is.character(txt_input),msg = "Wrong input format")

list.a <- as.list(c(LETTERS[1:8]))
list.b <- as.list(c(1:8))
result.df <- expand.grid(list.a, list.b)

library(purrr)
possible_cmds<- list(
  first_element = c(LETTERS[1:8]),
  second_element = c(1:8),
  sep = ""
)
combo <- as.list(possible_cmds) %>% cross() %>% map(lift(paste)) 

#Extract text from transcribed string
word(txt_input, start = 1,end = -1, sep = fixed("and"))
initial_position <- word(txt_input, start = 1,end = 1)
final_position <- trimws(word(txt_input, start = 2,end = -1, sep = fixed("and"))) #trims leading and trailing whitespaces

#Capture move exception here
possible_cmds<- list(
  first_element = c(LETTERS[1:8]),
  second_element = c(1:8),
  third_element = " capture.",
  sep = ""
)
capt_comb <- as.list(possible_cmds) %>% cross() %>% map(lift(paste)) 
assert(initial_position %in% combo,msg = "Start position should be a chess board location",stop = TRUE)

if(final_position %in% capt_comb){
  print("Capture algorithm here") #Capture algorithm here
  
} else {
  assert(substr(final_position,1,2) %in% combo,msg = "Final position should be a chess board location",stop = TRUE)
  final_position <- substr(final_position,1,2) #removes trailing fullstop
}


initial_position <- initial_position
final_position  <- final_position


# To do Ian: --------------------------------------------------------------

# convert speech to keywords such as A1, B2, Capture ###DONE


# Speech_text to manipulator work space Transition------------------------------------
library(here)
library(waffle)
library(patchwork)
library(magick)
#library(tidyverse)

# Ensure the following lines run only once
if(exists("already_ran") == FALSE){
  
  already_ran <-  TRUE 
  # Vector of board arrangement
  x <- c(A= 1, B = 1, C = 1, D = 1, E = 1, F = 1, G = 1)
  y <- c(A= 1, B = 1, C = 1, D = 1, E = 1, F = 1, G = 1)
  
  # Create checker boxes
  w1 = waffle(x, rows = 8, flip = TRUE, colors = c("black", "white", "black", "white", "black", "white", "black", "white"), legend_pos = "", , size = 0.1) + 
    theme(plot.margin = margin(0, 0, 0, 0))
  w2 = waffle(y, rows = 8, flip = TRUE, colors = c("white", "black", "white", "black", "white", "black", "white", "black"), legend_pos = "", size = 0.1) +
    theme(plot.margin = margin(0, 0, 0, 0))
  
  # Make checker board
  checkerboard <- w1 / w2 / w1 / w2 / w1 / w2 / w1 / w2
  #checkerboard
  ggsave("checkerboard.png", plot = checkerboard, width = 7, height = 7)
  
  # Read Image into environment
  library(magick)
  img <- image_read("checkerboard.png") %>% 
    image_convert(type = "grayscale")
  
  # Specifying dimensions of virtual board
  dim_x = 160 * 4
  dim_y = 160 *4
  img <- image_resize(img, paste(dim_x, dim_y, sep = "x"))
  
  
  # Assign names to checker boards e.g A1, G7
  row_names = tibble(x = 1:dim_x, y = rep(LETTERS[1:8], each = dim_y/8), z = paste(x, "_", y, sep = "")) %>% pull(z)
  
  col_names = tibble(x = 1:dim_x, y = rep(1:8, each = dim_x/8), z = paste(x, "_", y, sep = "")) %>% pull(z)
  
  
  # Create array and number rows and columns
  img_array <- drop(as.integer(pluck(img, 1)))
  # rownames(img_array) <- 1:nrow(img_array)
  # colnames(img_array) <- 1:ncol(img_array)
  rownames(img_array) <- row_names
  colnames(img_array) <- col_names
  
  
  # Create data frame of checker board i.e pixel coordinates and location
  img_df <- img_array %>% 
    as_tibble() %>% 
    mutate(y = row_names) %>% 
    #rowid_to_column(var = "y") %>% 
    pivot_longer(!y, names_to = "x", values_to = "pv") %>% 
    mutate(pv = scales::rescale(pv, to = c(0, 1))) %>% 
    # binarize
    mutate(pv = case_when(
      pv > 0.5 ~ 1,
      TRUE ~ 0))
  
  
  img_dfx = img_df %>% 
    separate(y, c("y", "pl")) %>% 
    separate(x, c("x", "pn")) %>% 
    mutate(pos = paste(pl, pn, sep = "")) %>% 
    select(-c(pn, pl)) %>% 
    mutate(across(c(y, x, pv), as.numeric)) %>% 
    group_by(pos) %>% 
    mutate(centroidx = round(mean(x)), centroidy = round(mean(y))) %>% 
    ungroup()
  
  
  
  # Obtaining checker box centroid coordinates
  centroids <- img_dfx %>% 
    ungroup() %>% 
    distinct(pos, centroidx, centroidy)
  
  
  
  # Function that maps virtual board to manipulator work space
  # Used scales::rescale instead
  # map_fun <- function(value, from_low, from_high, to_low, to_high){
  #   
  #   mapped_val = (value - from_low) * (to_high - to_low) / (from_high - from_low) + (to_low)
  #   
  #   return(mapped_val)
  # }
  
  # Map virtual board coordinates to manipulator workspace
  centroids = centroids %>% 
    # mutate(x_mapped = map_fun(centroidx, from_low = 0, from_high = dim_x, to_low = 9, to_high = -9),
    #        y_mapped = map_fun(centroidy, from_low = 0, from_high = 192, to_low = 11, to_high = 17)) %>% 
    ## Use scales::rescale
    mutate(x_mapped = scales::rescale(centroidx, to = c(9, -9), from = c(0, 640)),
           y_mapped = scales::rescale(centroidy, to = c(11, 17), from = c(0, 192))) %>% 
    mutate(across(where(is.numeric), round)) %>% 
    # Rearrange board positions to match our physical chess board
    mutate(
      pl = rep(LETTERS[1:8], times = nrow(centroids)/8),
      pn = rep(1:8, each = nrow(centroids)/8),
      pos = paste(pl, pn, sep = "")) %>% 
    select(-c(pl, pn))
  
  
  # Function that returns xy coordinates give a box name
  get_centroid <- function(position){
    x = centroids %>% 
      filter(str_detect(pos, position)) %>% 
      pull(x_mapped)
    
    y = centroids %>% 
      filter(str_detect(pos, position)) %>% 
      pull(y_mapped)
    
    return(c(x, y))
  }
  
  ### Result of speech to text goes here!!
  # Example
  # xy=get_centroid(position = "A2")
  # xy
  
  
  # To do: Get what Ian outputs as text and pass it to get_centroid ---------
  
  #GETTING MAPPED XY COORDIANTED FROM FROM VOICE INPUT
  # xy_initial <- get_centroid(position = initial_position)
  # xy_final <- get_centroid(position = final_position)
  
  
  # Forward & Inverse kinematics ------------------------------------------------------
  
  # Function that calculates forward kinematics
  fkin <- function(motor_angles){
    
    # Convert to radians
    angles = motor_angles * pi/180
    
    # Extract angles
    theta1 = angles[1] 
    theta2 = angles[2]
    theta3 = pi - angles[3]
    
    # Calculate x, y, z
    x <- 4 * cos(theta1) *( (3*cos(theta2 + theta3)) + (2*cos(theta2)))
    
    y <- 4 * sin(theta1) *( (3*cos(theta2 + theta3)) + (2*cos(theta2)))
    
    z <- (12 * sin(theta2 + theta3)) + (8*sin(theta2)) - (11/2)
    
    
    # Return a tibble
    fkin <- tibble(
      
      orientation = c("x", "y", "z"),
      
      # Multiply by -1 to re-orient y and z
      # mistake made during finding DH
      
      position = round(c(x, y * -1, z * -1))
      
    )
    
    return(fkin)
    
  }
  
  # Function that calculates inverse kinematics
  ikin <- function(xyz_coordinates){
    
    # Extract xyz coordinates
    x = xyz_coordinates[1]
    y = xyz_coordinates[2]
    z = xyz_coordinates[3]
    
    # Account for manipulator moving right or left
    if (x >= 0){
      theta1 = atan(x/y) + pi/2
    } else {
      theta1 = atan(y/x) %>% abs()
    }
    
    # Calculate theta 3 since its needed in theta 2
    theta3 = acos((x^2 + y^2 + (z-5)^2 - 8^2 - 12^2) / (2*8*12))
    # 8 and 12 are the dimensions of manipulator arms
    
    
    # Calculate theta 2
    theta2 = atan((5.5 - z) / (sqrt(x^2 + y^2)) ) + 
      atan((12 * sin(theta3)) / (8 + 12*cos(theta3)))
    
    if(theta2 > 0){
      theta2 = pi - abs(theta2)
    }
    
    # tbl <- tibble(
    #   ef_position = c(x, y, z),
    #   motor_angles = (c(theta1, theta2, pi-theta3)*180/pi) %>% round()
    # )
    
    
    
    #return(tbl)
    
    motor_angles = (c(theta1, theta2, pi-theta3)*180/pi) %>% round()
    return(motor_angles)
    
  }
  
  ## Example
  #ikin(xyz_coordinates = c(0, 13, 5))
  
  # Define xyz
  #z = ?
  #xyz = c(xy, z)
  
  # Motor angles for xyz
  #motor_angles <- ikin(xyz_coordinates = xyz)
  
  
  ### INVOKING INVERSE KINEMATICS(MANIPULATOR MOVEMENT)-------------------------------------------------
  
  # Initial and final angles
  # z = 3.5
  # xyz_initial <-  c(xy_initial, z)
  # xyz_final <-  c(xy_final, z)
  # 
  # initial_angles <-  ikin(xyz_coordinates = xyz_initial) %>% 
  #   pull(motor_angles)
  # 
  # final_angles <- ikin(xyz_coordinates = xyz_final) %>% 
  #   pull(motor_angles)
  
  
  # TRAJECTORY --------------------------------------------------------------
  
  # Tracing a trajectory can help achieve a smoother motioN
  
  # Ian: How do we modify this for multiple values?
  # MODIFY FOR MULTIPLE VALUES--------------------------------------------------
  
  
  #library(matlib)#found a better alternative to this ==> use solve instead to find the inverse
  
  
  # Velocity and acceleration constraints
  v_init = 0
  v_fin = 0
  acc_init = 0
  acc_fin = 0
  
  #We desire our motion to be executed in a span of two seconds
  t0 = 0
  tfin= 2
  
  #finding the coefficients a0 - a5 using velocity and acceleration constraints set above
  t_elements = c(1, t0, t0^2, t0^3, t0^4, t0^5,
                 0, 1, 2*t0, 3*t0^2, 4*t0^3, 5*t0^4,
                 0, 0, 2, 6*t0, 12*t0^2, 20*t0^3,
                 1, tfin, tfin^2, tfin^3, tfin^4, tfin^5,
                 0, 1, 2*tfin, 3*tfin^2, 4*tfin^3, 5*tfin^4,
                 0, 0, 2, 6*tfin, 12*tfin^2, 20*tfin^3
  )
  
  
  
  #init_theta = 65 
  #fin_theta =  135
  
  gen_traj <- function(init_theta, fin_theta){
    
    
    t_mtx = matrix(t_elements, nrow = 6, ncol = 6, byrow = TRUE)
    const_mtx_elmnts = c(init_theta, v_init, acc_init, fin_theta, v_fin, acc_fin) #constraints matrix
    const_mtx = matrix(const_mtx_elmnts,nrow = 6, ncol = 1, byrow = TRUE)
    a_mtx = solve(t_mtx) %*% const_mtx
    a_mtx = as.data.frame(a_mtx)
    
    #Substituting coefficient values into the quintic polynomial 
    #defining matrix time interval
    t = c(seq(from = 0, to = 2, by = 2))
    time <- matrix(t,nrow = length(t), ncol = 1, byrow = TRUE )
    traj <- vector("numeric", length(t))
    x = 1
    for(x in 1:length(t)){
      t = time[x,1]
      
      q_poly = a_mtx[1,1] + a_mtx[2,1]*t + a_mtx[3,1]*t^2 + a_mtx[4,1]*t^3 + a_mtx[5,1]*t^4 + a_mtx[6,1]*t^5 #equation 7 with coefficients substituted
      
      x =x+1
      
      traj[x] <- q_poly
    }
    
    traj = round(traj)
    traj <- traj[2:length(traj)]
    df_traj = tibble(traj)
    return(df_traj)
    #return(traj)
    
  }
  
  
  #cv=gen_traj(init_theta = 65, fin_theta = 135)
  
  # To do: Modify trajectory to take multiple values ------------------------
  #DONE------------------------------
  
  # Function that calculates trajectory angles and creates a tibble
  # with columns for each servo
  join_traj <- function(path_start, path_end){
    # Calculate trajectory
    traj_str = suppressMessages(map2_dfc(path_start, path_end, gen_traj)) %>% 
      `colnames<-`(LETTERS[1:ncol(.)]) %>% 
      mutate(across(everything(), ~ paste(.x, cur_column(), sep = ""))) %>% 
      rowwise() %>% 
      mutate(traj = paste(cur_data(), collapse = "")) %>% 
      ungroup() %>% 
      distinct(traj) %>% 
      pull(traj)
    
    return(traj_str)
  }
  
  
} # End of run once
# Make a list of trajectories for each path the manipulator will take
OUT = c(13, 11.25, 3.5)
start_angles <-  ikin(xyz_coordinates = c(get_centroid(position = initial_position), 12))
end_angles <- ikin(xyz_coordinates = c(get_centroid(position = final_position %>% str_remove("capture.") %>% str_trim()), 12)) 
rest = c(90, 90, 90)




if (str_detect(final_position, "capture")){
  # Trajectory angles
  OUT_angles <- ikin(xyz_coordinates = OUT)
  rest = c(90, 90, 90)
  
  # Trajectory
  # rest %>% ea %>% out %>% rest %>% sa %>% rest %>% ea %>% rest
  # Remove a lot of RESTs
  path = list(rest, end_angles, OUT_angles, start_angles, end_angles, rest)
  path_traj = map(seq_len(length(path)-1), ~ join_traj(path %>% pluck(.x), path %>% pluck(.x+1)))
  
  
} else {
  
  # Trajectory
  # rest %>% sa %>% rest %>% ea %>% rest
  # path = list(rest, start_angles, rest, end_angles, rest)
  path = list(rest, start_angles, end_angles, rest)
  path_traj = map(seq_len(length(path)-1), ~ join_traj(path %>% pluck(.x), path %>% pluck(.x+1)))
  
  
}



#R TO ARDUINO ME ARM

library(serial)

# See the ports available
# listPorts()

# Create an Arduino object and set up the interface parameters.
arduino = serial::serialConnection(name = "aRduino",
                                   port = "COM9",
                                   mode = "9600,n,8,1" ,
                                   buffering = "none",
                                   newline = TRUE,
                                   eof = "",
                                   translation = "cr",
                                   handshake = "none",
                                   buffersize = 8096)

# Function to clear arduino object
clear = function(){
  arduino <<- arduino
  close(arduino)
  open(arduino)
  # Any need to remove the arduino object from env like in MATLAB?
  
}

# Initialize the interface
#close(arduino)
open(arduino)
Sys.sleep(2)

# Function to write to arduino
write_angles <-  function(angles){
  write.serialConnection(arduino, angles)
  Sys.sleep(0.4)
}

# Write angles to arduino object
# Find a way to do this with walk?
# Disable trajectory for now
for (i in 1:length(path_traj)){
  if (i%%2 != 0){
    write.serialConnection(arduino, "110D")
    walk(path_traj %>% pluck(i), ~ write_angles(.x))
    Sys.sleep(0.4)
  } else {
    Sys.sleep(0.4)
    write.serialConnection(arduino, "20D")
    walk(path_traj %>% pluck(i), ~ write_angles(.x))
  }
}

#walk(1:length(path_traj), ~ walk(path_traj[[.x]], ~ write_angles(.x)))


# read the values sent to the serial port connection by 
# Arduino script 
data_frm_arduino <- tibble(from_arduino = capture.output(cat(read.serialConnection(arduino)))) %>% 
  filter(if_any(where(is.character), ~ .x != "")) %>% 
  mutate(from_arduino = as.integer(from_arduino))


# data_frm_arduino

clear()