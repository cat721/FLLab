if [ -d "fabric-client-kv-org*" ]; then
  rm -rf "fabric-client-kv-org*"
fi
bash enroll.sh
cd ..
node test/start.js
sleep 10
node test/start1.js
