for file in *converted*.wav; do
    mv "$file" "${file/_converted/}"
done

