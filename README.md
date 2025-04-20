# CMPM121Solitaire
 This is a recreation of Klondike Solitaire, created for CMPM121, game development patterns. 
 
Programming Patterns Utilized: 
Flyweight Pattern -- Used to manage the creation and logic for cards. 
FSM -- Used to manage Game State Transitions, menu, playing, win
Update -- Used to actively update objects each frame
State -- Used for card states, things like idle, mouseOver, or grabbed 

Postmortem: 
This project was pretty fun. As always, I might have liked more time to make it polished, but I was pretty pleased with what I created. I ended up using Zac's starter code from class, and I think it helped by giving me a simple base to expand upon. Things that came easily were building the deck, and the core interactions. Picking up the cards, tracking the mouse, enforcing things like descending color and alternating suit all came fairly smoothly. What I struggled the most on were some of the stacking interactions and layering logic. Dealing with the cardtable, and tracking whether cards should be managed through my piles table, or the card table on release was an issue at first. I was initially drawing from both for some of my interactions which caused errors and sadness. If I were to do this project again, I think I wouldn't track the cardTable and Piles separately. I think if I would have just used Piles to do everything, it might have been less confusing. I'd probably also use a real UI framework to make it a lot more visually pleasing. I also would have added some music and sound effects. 

Assets: 
Title Screen Art -- CHATGPT image generation
Fonts: https://sourceforge.net/projects/dejavu/files/dejavu/2.37/dejavu-fonts-ttf-2.37.zip/download

