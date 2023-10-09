bring "../containers.w" as containers;
bring http;

let message = "hello, wing!";

let hello = new containers.Workload(
  image: "paulbouwer/hello-kubernetes:1",
  port: 8080,
  readiness: "/",
  env: {
    "MESSAGE" => message,
  }
);

let getBody = inflight (): str? => {
  if let url = hello.url() {
    return http.get(url).body;
  }

  return nil;
};

test "container started automatically and port exposed" {
  let body = getBody();
  assert(body?.contains(message) ?? false);
}

test "container stopped after stop() is called" {
  assert(getBody()?);

  // stop the container and check that there is no body
  hello.stop();

  // check that we can't reach the container
  let var error = false;
  try {
    getBody();
  } catch {
    error = true;
  }
  assert(error);
}