#!/bin/bash
# written by sanjiv kawa
# twitter: kawabungah

mkdir web
if [ -e web/asciinema-player.css ]
then
    echo ""
else
	wget https://github.com/asciinema/asciinema-player/releases/download/v2.6.1/asciinema-player.css -O ./web/asciinema-player.css
	wget https://github.com/asciinema/asciinema-player/releases/download/v2.6.1/asciinema-player.js -O ./web/asciinema-player.js
fi

rm ./index.html

cat << EOF > ./index.html
  <html>
  <head>
    <link rel="stylesheet" type="text/css" href="./web/asciinema-player.css" />
  </head>
  <body>
EOF
for i in $(ls *.json); do
    echo "  <h2>$i</h2>" >> index.html;
    echo "  <asciinema-player src=\"./$i\"></asciinema-player>" >> index.html;
    echo "  " >> index.html;
done
cat << EOF >> ./index.html
    <script src="./web/asciinema-player.js"></script>
  </body>
  </html>
EOF
echo "[+] Please go to http://127.0.0.1:9999"
ruby -run -e httpd ./index.html --bind-address=127.0.0.1 -p 9999
