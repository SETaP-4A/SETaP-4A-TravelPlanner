# Software Engineering Theory 4A

Repository for group work.

## Project Overview

This project is a collaborative Flutter-based application designed to simplify travel planning and sharing. It enables users to create detailed itineraries, manage flights, accommodations, activities, and packing lists. The app emphasises collaboration, allowing users to invite friends with specific permissions, ensuring seamless group travel coordination. Real-time updates, offline access, and customisable settings like light/dark mode further enhance the user experience.

## Features List

* **Itinerary Creation and Management**: Easily create and organise travel plans with intuitive controls.
* **Flight, Accommodation, and Activity Tracking**: Detailed input and management for all travel essentials.
* **Collaborative Trip Sharing**: Invite friends with viewer or editor permissions, enabling real-time collaboration.
* **Offline Access and Real-time Updates**: Access your travel plans offline and enjoy automatic real-time synchronisation.
* **Notification Management**: Receive timely updates and reminders about your trip details.
* **Customisation**: Personalise your experience with light and dark mode options.

## Technologies Used

* **Flutter**: Cross-platform mobile app development framework.
* **Firebase**: Real-time database and authentication services.
* **SQLite**: Local database management for offline functionality.
* **Java 17**: Required for compiling Android builds with Gradle.

# How To Set Up:

Download Fork - https://git-fork.com/
Go To:
https://github.com/SETaP-4A/SETaP-4A-TravelPlanner

Click the green "<> Code" button on the top right of the repository
Select Local > HTTPS     And then copy the Repository URL

Go to Fork
Click File > Clone
Paste the Repository URL
Select the Parent Folder where you would like the project to be locally stored (It will create its own contained folder for the project.)
Input W/E name you want to call the project (This is the name of the folder)

# How To Create a new branch:

Right Click the Branches tab on the left side

Select New Branch

Name the branch whatever the current task is (E.G. API Delete)

Tick the box "Check out after create" (This selects that branch to be currently used on your local machine)

Press the create button

NOTE: If you forget to tick the button to check out the branch afterwards, you can just double click the branch on the left to check out

# How to push changes to Git Hub    -     Avoid pushing work directly onto the Main branch

Once you have changes you wish to submit, Open Fork and press "Local Changes" on the top left. Make sure the group project is what Fork is focusing on.

Click on any file in the unstaged window and check to see if the changes on the local machine are correct. (This is where you can discard specific changes that may have been accidental)

Once happy, Double Click the files in the "Unstaged" window to move them to Staged

Give the commit a subject (The title of whats been changed) and a description (will probably help us out later on for documentation purposes)

Click the bottom left drop down arrow and select "Commit and Push"

Note: If you committed and didnt select "Commit and Push", then you can click the push arrow in the top left.

# Refreshing Local Project

To retrieve the most up to date changes and ongoing branches, press the Fetch button on the top left. This will let you see what other people have committed (if anything has been added)

# Fetching Changes from the server

If your Main branch is out of date after fetching from the server, click the Pull button and select:
Remote: Origin
Branch: origin/main
Click Fetch

# JDK Setup for Android Builds

This project requires Java 17 to compile the Android app using Gradle.

Step 1 — Download JDK 17
Download and install JDK 17 (Hotspot) from the following:

Adoptium JDK 17
https://adoptium.net/en-GB/temurin/releases/?version=17

Choose the version for your platform (ZIP or installer)

Extract or install it to a location of your choice

Step 2 — Point Gradle to the JDK
If Gradle doesn’t automatically detect your Java install, you’ll need to manually specify the path. NOTE: ADDING THE PATH VARIABLE CAN BE A POSSIBLE SOLUTION

Do manually add the path:  edit the following line to android/gradle.properties {Line 4} to specify your file path:

E.g.
org.gradle.java.home=C:/Users/theog/Downloads/OpenJDK17U-jdk\_x64\_windows\_hotspot\_17.0.14\_7/jdk-17.0.14+7

# NOTE: IF THE android/gradle.properties DOESN'T EXIST WITHIN THE ROOT DIR, YOU CAN DOWNLOAD A COPY AT:

https://drive.google.com/file/d/1dApglPQtSQqhCjMZlPZqHV6GbYbvkDiS/view?usp=sharing

Once that’s done, your Gradle builds should work smoothly for Android.
