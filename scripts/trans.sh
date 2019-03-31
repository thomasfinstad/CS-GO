#!/bin/bash

#trans -show-original-phonetics n -show-translation-phonetics n -show-prompt-message n -show-dictionary n -show-prompt-message n -show-alternatives n

while read new_line; do
    #echo "new_line: $new_line"
    if [[ "$new_line" == "trans.sh pls fix" ]]; then
        echo "-=====New translation job $(date '+%F %T')=====================-"
        you="$(cat csgo/csgo_console.log | tac | grep -iEo 'Player:.* - Damage ' | head -n1 | sed 's/^Player: \(.*\) - Damage $/\1/')"

        lines_processed=0
        while read process_line; do
           if [[ "$lines_processed" -gt 4 ]]; then
               break;
           fi
           if [[ "$process_line" == "trans.sh pls fix" ]]; then
               continue
           fi
           if [[ "$process_line" == "$you"* ]]; then
               #echo "you"
               continue
           fi
           lines_to_translate="${lines_to_translate}${process_line}\n"
           #echo "lines_to_translate rev: $lines_to_translate"
           lines_processed=$(($lines_processed + 1))
           #echo "lines_processed: $lines_processed"
        done < <(tail -n 100 csgo/csgo_console_talk.log | tac)

        lines_to_translate="$(echo -e $lines_to_translate | tac | tail -n +2)"
        #echo -e "lines_to_translate: $lines_to_translate"

        while read line; do

            if [[ "x" == "x$line" ]]; then echo "ERR line empty"; continue; fi

            player="$(echo "$line" | grep -oE "^.* : " | sed 's/ : //')"
            message="$(echo "$line" | grep -oE " : .*$" | sed 's/ : //')"


            echo "$player : $message"
            #echo "$message"
            #echo "$message" | trans -no-ansi -b
            echo -n "$message" | trans -no-ansi -show-original-phonetics n -show-translation-phonetics n -show-prompt-message n -show-dictionary n -show-prompt-message n -show-alternatives n -show-original n 2>&1
            echo "--------------------------------------------"
        done < <(echo -e "$lines_to_translate")
    echo 
fi
done < /dev/stdin
