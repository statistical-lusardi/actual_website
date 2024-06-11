---
title: Automating Real-Time Electrical Load Monitoring 
author: Anthony Lusardi
date: '2024-06-11'
slug: []
categories:
  - fun
  - Python
  - data visualization
tags:
  - plot
  - fun
hero: /images/posts/Real Time Electrical Map/angle shot.jpg
---
While paternity leave was a great time with Milo, I needed some time to tinker with a new hobby and decorate my new home office. Usually, I spend time beer brewing, but this time I wanted to learn a new skill: Python and Raspberry Pi.

#### Project Inspiration

I got the original idea from a combination of projects, particularly Sarah Rueker's LED-powered METAR map and the awesome data visualization of EIA's Hourly Electric Grid Monitor. I wanted to have a physical representation of the hourly electric grid monitor but I also wanted it to autoupdate each hour. In this post I describe how I accomplished that.

#### Supplies Needed
Here's a list of the things that I used:

- Raspberry Pi Zero W: This kit comes with a nice case, the pin headers, and a power supply, - but you could also buy those separately.
- Micro SD Card to install Raspberry Pi OS Lite.
- WS2811 Addressable LEDs.
- Wires to connect Raspberry Pi to LEDs.
- Your choice of 36 x 24 inch map of the US 
- Soldering Iron to attach the pin headers to the Raspberry Pi.
- Foam Board to glue LEDs into from your local crafts or stationary store.I got mine from Target
- Shadow Box Frame (in my case I built a 36 x 24 inch frame for it).
- Some Transparent Sheets to transfer the location of the airports from your sectional to  the  board for drilling (I just drew on the plastic cover for the foam board).
- Glue Stick to attach the sectional chart onto the board.
- Glue Gun (or super glue would probably also work) to affix the LEDs to the board.

#### Assembling the Map

{{< img src="images/wireback.jpg" float="left" >}}

I used the map and the cover of the foam board to map out the locations where the LEDs would be placed. I then transferred these locations to the foam board and drilled holes to accommodate the LEDs. Actually, I used a pen to punch holes because drilling tended to tear up the foam too much.

{{< img src="images/wiring.jpg" float="left" >}}

#### Software and Wiring

 I flashed the Raspberry Pi OS Lite onto the micro SD card and set up the Raspberry Pi Zero W. I pretty much followed the METAR map instructions on Sarah Rueker's link, which had extremely helpful troubleshooting and FAQs.

I connected the WS2811 addressable LEDs to the GPIO pins on the Raspberry Pi. Mapping of pins is also available at the METAR map link. Make sure to always test your pins and lights before securing them.

I then mounted the map onto the foam board using a glue stick. After placing the LEDs into the drilled holes on the foam board, I secured them with Gorilla Glue.


#### Finished Product 
I then placed the assembled board into a custom shadow box frame I made for a polished look in the home office.

{{< img src="images/front on picture.jpg" float="left" >}}

And voila! Each hour, this map updates with the latest data from the EIA. It adds such a cool level of depth to the office and makes for a great talking piece about the grid for anyone visiting.

For a timelapse of 24 hours of updates, you can see the below animation of what it would look like.
{{< img src="images/gif.gif" float="left" >}}

##### Python Code for Real-Time Data

Here's the Python code that makes it all work. This script queries real-time operation data from the EIA for each of the balancing authorities, updating the LED colors based on the percent change of load hour to hour. Blue indicates a drop in load, and red indicates a sharp increase in load. No light represents no data or small changes to load.


### Links and References

Making a LED powered METAR map for your wall:
https://slingtsi.rueker.com/making-a-led-powered-metar-map-for-your-wall/

EIA HOURLY ELECTRIC GRID MONITOR:
https://www.eia.gov/electricity/gridmonitor/dashboard/electric_overview/US48/US48

Python Code for API Pull:
https://github.com/statistical-lusardi/Energy-Map/blob/main/EIA_Pull_python.py

