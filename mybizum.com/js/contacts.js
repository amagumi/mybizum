function getContacts() {
    let url = "http://ws.mybizum.com:8080/ws.php?action=listusers";
    let AJAX = new clsAjax(url, null);

    document.addEventListener('__CALL_RETURNED__', onContactsResponse);

    AJAX.Call();

    function onContactsResponse() {
        let response = AJAX.xml;
        let parser = new DOMParser();
        let xmlDoc = parser.parseFromString(response, "text/xml");

        let numErrorElement = xmlDoc.getElementsByTagName("num_error")[0];

        if (numErrorElement && numErrorElement.textContent === "0") {
            // ✅ Selección precisa del <select>
            let selectElement = document.getElementById("contacts-select");

            selectElement.innerHTML = "<option disabled selected>Selecciona un contacto</option>";

            let users = xmlDoc.getElementsByTagName("user");

            for (let i = 0; i < users.length; i++) {
                let username = users[i].getElementsByTagName("username")[0]?.textContent || "";
                let name = users[i].getElementsByTagName("name")[0]?.textContent || "";

                let option = document.createElement("option");
                option.value = username;
                option.textContent = `${name} (${username})`;

                selectElement.appendChild(option);
            }

            document.removeEventListener('__CALL_RETURNED__', onContactsResponse);
        } else {
            alert("Error al cargar usuarios.");
        }
    }
}

window.onload = function () {
    getContacts();

    document.getElementById("contacts-select").addEventListener("change", function () {
        document.getElementById("receiver").value = this.value;
    });
};
