#!/bin/bash

# To use YAD/zenity to create config file easily.
# FLOW
# 
# 1 - Set default value (with explanation)
# 2 - Set top level genres (for those that exist in MPD)
# 3 - Set subgenres (for those that exist in MPD)
# 4 - Save whole shebang

#using Genre array from MPDQ
#"${Genre[$i]}" 
#printf "%s\n"  "${Genre[@]}" | grep "Pop"


does_genre_exist() {
    #Needs to be exact string, NOT case sensitive
    #printf "%s\n"  "${Genre[@]}" | grep "${1}"
    #if there, return 0, else return 99
}

list_top_genres() {

    # For each file in config directory (from globals)
    # check if is a genre (NOT case sensitive!)
    # if is genre, add to Top_Level array, with associated default value from DEFAULT
    # 
 
    
}

list_second_genres() {
    # needs to read all top level files! 
    # if a top level didn't exist, give them all DEFAULT value in that file
    
}


list_genres_not_caught() {
    # compare $Genre[@] with our built genre list
    # anything NOT in both gets offered up now, with DEFAULT value.
}


select_default_value(){
    
}

write_instruction_file() {
    
}

