# rstudio_conf22_R_in_robotics
## rstudio::conf(2022) talk: A Touch of R in Robotics 
## Me Arm
This repo contains code that we used to achieve robotic arm actuation using R, presented during the rstudio::conf(2022) conference. In this presentation, we used the open source [ME arm robotics kit](https://mearm.com/resources-and-files/). A guide on how to assemble the arm can be found [here](https://www.instructables.com/MeArm-Build-a-Small-Hackable-Robot-Arm/). Note: The design of the me Arm varies between different versions, ensure the assembly guide you follow is appropriate to the me arm robotics kit you have. We got our me Arm kit from this [site](https://www.pixelelectric.com/more-categories/robots/gripper-arm/4-dof-acrylic-robot-arm-arduino/?setCurrencyId=2). Incase you have access to a laser cutting machine, you can download the design schematics from [instructables](https://www.instructables.com/Pocket-Sized-Robot-Arm-meArm-V04/) and build the arm from scratch. <br />
 ![Me Arm Assembly](https://github.com/R-icntay/rstudio_conf22_R_in_robotics/blob/main/torr/images/20220713_223306.jpg) <br />
 The key concepts we used to achieve this were:
 * audio recording and transcription
 * image processing
 * Inverse kinematics
 * Serial link communication <br />
 Each of this section is elaborated in detail in this repo and finally, everyhting is combined to achieve a voice controlled robotic arm.
 
 ## Result upon combinig all the three modules highlighted above
https://user-images.githubusercontent.com/56159134/181566714-0a09f34e-427d-4c6f-bbf1-aff224fa25bd.mp4

