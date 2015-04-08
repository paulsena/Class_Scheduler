Paul Senatillaka
Project Course work for UML Organization of Programming Languages

![alt](https://raw.githubusercontent.com/paulsena/Class_Scheduler/master/ss2.jpg)
![alt](https://raw.githubusercontent.com/paulsena/Class_Scheduler/master/ss1.jpg)

Files:
classscheduler-parser.rkt  - Main work hourse of parsing html and creating permutations of schedules.
classscheduler-webserver.krt - Webserver code to display results and get input from user
ps-diagram.jpg - Diagram of code flow

Description of code:
The parser module will parse the registrar's website and store the information for each class in a struct. A list of these structs is compiled and defined on startup. Once the user enters a few courses they would like to take, the master list is filtered down to include just the ones they selected. There is a sublist for each section # of a given course. The next step of functionality involves creating permutations of all possible schedules with all the class sections. Map is used here. Finally the results are displayed to the user. Html is generated here using xexpressions and Map again to create the row entries of a html table.

How to Run:
Load the webserver code and run. A browser window will open shortly where you can interact with the application. For this demo I used a shortened list of urls to parse registry information from because the full registring listing took too long, so make sure to choose all your classes from these or the result will be empty since when filtering it won't be able to find a class schedule with that invalid class in it.  I've included Comp Sci, Biology, CHemistry, Environ Sci, Math, Physics. Pretty much all the sciences.

Diagram:
(https://raw.githubusercontent.com/paulsena/Class_Scheduler/master/ps-diagram.jpg)
