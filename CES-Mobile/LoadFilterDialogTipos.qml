import QtQuick 2.0

Item {

    id: item1

    Component.onCompleted: requestHttp.get("tipos_objetos/")

    RequestHttp {
        id: requestHttp
        onFinished: {
            if (statusCode == 200) {
                var objectsTypes = []
                for (var i = 0; i < response.length; ++i) {
                   objectsTypes.push(response[i])
                }

                window.objectTypes = objectsTypes
            }

        }

    }

}
