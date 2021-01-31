# Bind

## UDP, TCP DNS Server

```
main() {
  docker build . -t local/bind
  docker run --rm --name bind  -p 3053:53 -p 3053:53/udp -d local/bind
  echo -n "weit for running 3.."
  for i in {2..0}
  do
    sleep 1.1
    echo -n "$i.."
  done
  echo
  time dig google.co.jp @127.0.0.1 -p 3053
  time dig jsx.jp @127.0.0.1 -p 3053
  docker stop bind
}
main
```
