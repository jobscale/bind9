# Bind

## UDP, TCP DNS Server

```
main() {
  docker build . -t local/bind9
  docker run --rm --name bind9  -p 172.16.6.22:53:53 -p 172.16.6.22:53:53/udp -d local/bind9
  echo -n "weit for running 3.."
  for i in {2..0}
  do
    sleep 1.1
    echo -n "$i.."
  done
  echo
  time dig google.co.jp @172.16.6.22
  time dig jsx.jp @172.16.6.22
  docker stop bind9
}
main
```
