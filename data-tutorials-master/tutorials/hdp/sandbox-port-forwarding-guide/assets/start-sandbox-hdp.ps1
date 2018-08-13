Write-Host "Checking docker daemon..."
If ((Get-Process | Select-String docker) -ne $null) {
    Write-Host "Docker is up and running"
}
Else {
    $Host.UI.WriteErrorLine("Please start Docker service. https://docs.docker.com/docker-for-windows/")
    return
}

If ((docker images | Select-String sandbox-hdp) -ne $null) {
    Write-Host "Found sandbox image"
}
Else {
    $Host.UI.WriteErrorLine("Please download and load the sandbox image. https://hortonworks.com/downloads/#sandbox")
    return
}

If ((docker ps -a | Select-String sandbox-hdp) -ne $null) {
    Write-Host "Sandbox container already exists"
}
Else {
    Write-Host "Running sandbox for the first time..."
    docker run -v hadoop:/hadoop --name sandbox-hdp --hostname "sandbox.hortonworks.com" --privileged -d `
    -p 6080:6080 `
    -p 9090:9090 `
    -p 9000:9000 `
    -p 8000:8000 `
    -p 8020:8020 `
    -p 42111:42111 `
    -p 10500:10500 `
    -p 16030:16030 `
    -p 8042:8042 `
    -p 8040:8040 `
    -p 2100:2100 `
    -p 4200:4200 `
    -p 4040:4040 `
    -p 8050:8050 `
    -p 9996:9996 `
    -p 9995:9995 `
    -p 8080:8080 `
    -p 8088:8088 `
    -p 8886:8886 `
    -p 8889:8889 `
    -p 8443:8443 `
    -p 8744:8744 `
    -p 8888:8888 `
    -p 8188:8188 `
    -p 8983:8983 `
    -p 1000:1000 `
    -p 1100:1100 `
    -p 11000:11000 `
    -p 10001:10001 `
    -p 15000:15000 `
    -p 10000:10000 `
    -p 8993:8993 `
    -p 1988:1988 `
    -p 5007:5007 `
    -p 50070:50070 `
    -p 19888:19888 `
    -p 16010:16010 `
    -p 50111:50111 `
    -p 50075:50075 `
    -p 50095:50095 `
    -p 18080:18080 `
    -p 60000:60000 `
    -p 8090:8090 `
    -p 8091:8091 `
    -p 8005:8005 `
    -p 8086:8086 `
    -p 8082:8082 `
    -p 60080:60080 `
    -p 8765:8765 `
    -p 5011:5011 `
    -p 6001:6001 `
    -p 6003:6003 `
    -p 6008:6008 `
    -p 1220:1220 `
    -p 21000:21000 `
    -p 6188:6188 `
    -p 61888:61888 `
    -p 2222:22 sandbox-hdp /usr/sbin/sshd -D | Out-Null
}

If ((docker ps | Select-String sandbox-hdp) -ne $null) {
    Write-Host "Sandbox started"
}
Else {
    Write-Host "Starting sandbox..."
    docker start sandbox-hdp | Out-Host
}

Write-Host "Starting processes on the sandbox..."

docker exec -t sandbox-hdp make --makefile /usr/lib/hue/tools/start_scripts/start_deps.mf  -B Startup -j -i | Out-Host
docker exec -t sandbox-hdp nohup su - hue -c '/bin/bash /usr/lib/tutorials/tutorials_app/run/run.sh' |  Out-Host
docker exec -t sandbox-hdp touch /usr/hdp/current/oozie-server/oozie-server/work/Catalina/localhost/oozie/SESSIONS.ser | Out-Host
docker exec -t sandbox-hdp chown oozie:hadoop /usr/hdp/current/oozie-server/oozie-server/work/Catalina/localhost/oozie/SESSIONS.ser | Out-Host
docker exec -d sandbox-hdp /etc/init.d/tutorials start | Out-Host
docker exec -d sandbox-hdp /etc/init.d/splash | Out-Host
#docker exec -d sandbox-hdp /etc/init.d/shellinaboxd start | Out-Host

Write-Host "Sandbox is good to do.  Press any key to continue..."
$x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")

return
