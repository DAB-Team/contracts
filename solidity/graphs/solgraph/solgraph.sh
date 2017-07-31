
rm -rf *.png

for i in $(ls ../../contracts)
do

    filename=${i%.*};
    extension=${i##*.};
    if [ "$extension" == "sol" ]; then
        echo $i;
        solgraph "../../contracts/"$i | dot -Tpng > $filename.png;
    fi

done

for i in $(ls ../../contracts/helpers)
do

    filename=${i%.*};
    extension=${i##*.};
    if [ "$extension" == "sol" ]; then
        echo $i;
        solgraph "../../contracts/helpers/"$i | dot -Tpng > $filename.png;
    fi

done


for i in $(ls ../../contracts/interfaces)
do

    filename=${i%.*};
    extension=${i##*.};
    if [ "$extension" == "sol" ]; then
        echo $i;
        solgraph "../../contracts/interfaces/"$i | dot -Tpng > $filename.png;
    fi

done
