function logout() {
    let url = "http://ws.mybizum.com:8080/ws.php?action=logout";
    let AJAX = new clsAjax(url, null);

    document.addEventListener('__CALL_RETURNED__', function () {
        let response = AJAX.xml;
        console.log("Logout response:", response);

        let parser = new DOMParser();
        let xmlDoc = parser.parseFromString(response, "text/xml");
        let numErrorElement = xmlDoc.getElementsByTagName("num_error")[0];

        if (numErrorElement) {
            let numError = numErrorElement.textContent;
            if (numError === "0" || numError === "100") {
                window.location.href = "../pages/logout.php";
            } else {
                let msg = xmlDoc.getElementsByTagName("message")[0]?.textContent || "Logout fallido.";
                alert(msg);
            }
        } else {
            alert("Respuesta inválida del servidor.");
        }
    });

    AJAX.Call();
}
