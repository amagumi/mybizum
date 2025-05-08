document.getElementById("loginform").addEventListener("submit", function (event) {
    event.preventDefault();
    let action = document.getElementById("action").value;
    let username = document.getElementById("username").value;
    let password = document.getElementById("password").value;
  
    callservice(action, username, password);
  
  });
  
  
  // Enviar datos al servidor
  
  var AJAX;
  
  function callservice(action, username, password) {
  
    console.log("SEND----------------------------------");
  
    AJAX = new clsAjax("http://ws.mybizum.com:8080/ws.php?action=" + action + '&username=' + username + '&password=' + password, null);
    document.addEventListener('__CALL_RETURNED__', ReturnDataLogin);
    AJAX.Call();
    
  }
  
//   function ReturnDataLogin() {
  
//     let xmlString = AJAX.xml; // Recibe la respuesta XML como string
  
//     let parser = new DOMParser();
//     let xml = parser.parseFromString(xmlString, "text/xml"); // Convierte el string en XML
  
//     let numerError = xml.getElementsByTagName("num_error")[0]?.textContent;// 501 error, 0 success
//     }
