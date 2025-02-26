#!/bin/bash

greenColour="\e[0;32m\033[1m"
endColour="\033[0m\e[0m"
redColour="\e[0;31m\033[1m"
blueColour="\e[0;34m\033[1m"
yellowColour="\e[0;33m\033[1m"
purpleColour="\e[0;35m\033[1m"
turquoiseColour="\e[0;36m\033[1m"
grayColour="\e[0;37m\033[1m"



main_url="https://htbmachines.github.io/bundle.js"


function ctrl_c(){
    
    echo "\n\n ${redColour} [!] Saliendo......${endColour}"
    
}
trap ctrl_c INT

function helPanel(){
    echo -e "\t Este es el panel de ayuda "
    echo -e "\t ${blueColour} u) ${endColour}${grayColour} Decargar las actualizaciones ${endColour}"
    echo -e "\t${blueColour}  m) ${endColour}${grayColour}Buscar un nombre por maquina ${endColour}"
    echo -e "\t${blueColour}  d) ${endColour}${grayColour}Buscar por dificultad  ${endColour}"
    echo -e "\t${blueColour}  s) ${endColour}${grayColour}Buscar por sistema operativo ${endColour}"

}



serchMachine(){
machineName="$1"


verification=$(cat bundle.js | awk "/name: \"$machineName\"/, /resuelta:/" | grep -vE "id:|sku:|resuelta:" | tr -d "'" | tr -d "," | sed 's/^ *//')

if [ ! $verification ]; then 
     echo -e  "\n El nombre de la maquina ${blueColour}${machineName}${endColour}${redColour} [!] No existe ${endColour}\n"
else
   
    echo -e "\n${turquoiseColour}[+]${endColour}${grayColour}Listando las propiedades de la maquina ${endColour}${blueColour}$machineName${endColour}${grayColour}${endColour}\n"
    cat bundle.js | awk "/name: \"$machineName\"/, /resuelta:/" | grep -vE "id:|sku:|resuelta:" | tr -d "'" | tr -d "," 
fi


  
}


 serchMachineDifficulty(){
    dificulty="$1"
    echo -e "\n${turquoiseColour}[+]${endColour}${grayColour}Niveles de dificultad\n${redColour}Insane${endColour}\n${yellowColour}Difícil${endColour}\n${greenColour}Fácil${endColour}\n${endColour}\n"
    echo -e "\n${turquoiseColour}[+]${endColour}${grayColour}Listando maquinas por nivel de dificultad ${dificulty}\n"
    cat bundle.js | grep "$dificulty" -B 5 |  grep -vE "id:|sku:|resuelta:" | tr -d "'" | tr -d ","  | tr -d """" |  column
 }

searchSystem(){
  system="$1"
    echo -e "\n${turquoiseColour}[+]Buscando por sistema operativo${endColour}${grayColour} ${system} ${endColour}\n"
    cat bundle.js  | grep  "so: \"$system\"" -B 4 -A 5 | grep -vE "id:|sku:|resuelta:|skills:"| tr  -d '"' | tr -d "," | column      
 


}

updateFiles(){
    if [ ! -f bundle.js ]; then
        
        echo -e "\n ${blueColour}[+]${endColour}${grayColour} Descargando el archivo actualizado....."
        curl -s $main_url > bundle.js
        js-beautify bundle.js | sponge bundle.js
        echo -e "\n ${blueColour}[+]${endColour}${grayColour} El archivo a sido actualizado....."
        
    else
        echo -e "\n${yellowColour}[+]${endColour}${grayColour}Comprobado si existen actualizaciones pendientes.....${endColour}"
        curl -s $main_url > bundle_temp.js
        js-beautify bundle_temp.js | sponge bundle_temp.js
        md5_original_value=$(md5sum bundle.js | awk '{print $1}')
        md5_temporal=$(md5sum bundle_temp.js | awk '{print $1}')
        if [ $md5_original_value == $md5_temporal ]; then
            echo "[+] No hay actualizaciones disponibles, esta todo actualizado"
            rm bundle_temp.js
        else
            echo "Actualizando...."
            sleep 2
            rm bundle.js && mv  bundle_temp.js  bundle.js
            echo "Los archivos han sido actualizados [+] "
        fi
        
    fi
}


declare -i parameter_counter=0
while getopts "m:d:s:uh" arg; do
    case $arg in
        u) updateFiles; let parameter_counter+=1;;
        m) machineName=$OPTARG; let parameter_counter+=1;;
        d) dificulty=$OPTARG; let parameter_counter+=2;;
        s) system=$OPTARG; let parameter_counter+=3;;
        h);;
    esac
done

if [ $parameter_counter -eq 1 ]; then
    serchMachine $machineName
elif [ $parameter_counter -eq 2 ]; then
    serchMachineDifficulty $dificulty
elif [ $parameter_counter -eq 3 ]; then
    searchSystem $system
else
    helPanel
fi


