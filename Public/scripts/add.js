function process() {
  setLoading();
  FB.getLoginStatus(function(response) {
    const genderValue = genderSelect().value;
    if (!genderValue) {
      setError("First select your gender");
      return;
    }

    if (
      response &&
      response.authResponse &&
      response.authResponse.accessToken
    ) {
      fetch("/facebook/process", {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          Accept: "application/json"
        },
        body: JSON.stringify({
          gender: genderValue,
          access_token: response.authResponse.accessToken
        })
      })
        .then(response => response.json())
        .then(data => {
          if (data.error) {
            setError(data.reason || "Something went wrong...");
            return;
          }
          window.location.replace("/status/" + data.avatar_id);
        })
        .catch(error => {
          setError(error);
        });
    } else {
      setError("Something went wrong...");
    }
  });
}

function facebookButton() {
  return document.getElementById("fb-btn");
}

function loadingDiv() {
  return document.getElementById("loading");
}

function errorDiv() {
  return document.getElementById("error");
}

function genderSelect() {
  return document.getElementById("gender");
}

function reset() {
  facebookButton().style.display = "none";
  errorDiv().style.display = "none";
  loading.style.display = "none";
}

function setLoading() {
  facebookButton().style.display = "none";
  errorDiv().style.display = "none";
  loadingDiv().style.display = "block";
}

function setError(error) {
  facebookButton().style.display = "block";
  errorDiv().style.display = "block";
  errorDiv().innerHTML = error;
  loadingDiv().style.display = "none";
}
