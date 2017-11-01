import QtQuick 2.8
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.0

BasePage {
    title: qsTr("Histórico")
    objectName: "Historico.qml"
    listViewDelegate: pageDelegate
    onRequestUpdatePage: requestHttp.get("movimentacoes_usuario/" + window.user.id)
    toolBarActions: {
       "toolButton3": {"action":"filter", "icon":"filter"},
       "toolButton4": {"action":"search", "icon":"search"}
    }
    onRequestHttpReady: requestHttp.get("movimentacoes_usuario/" + window.user.id)

    property var objects
    property var selecionado

    function showDetail(delegateIndex) {
        pageStack.push("HistoricObjectDetails.qml", {"details":objects[delegateIndex]})
    }

    ListModel {
        id: buscaModel
    }

    ListModel {
        id: originalModel
    }

    Datepicker {
        id: datepicker
    }

    FilterDialog {
        id: filterDialog
        onAccepted: {
            // filterData
            if (originalModel.count == 0) {
                for (var i = 0; i < listViewModel.count; i++)
                    originalModel.append(listViewModel.get(i))
            }
            for (i = 0; i< originalModel.count; ++i) {
                var found = true
                var compareObjc = ({})
                var objc = originalModel.get(i)
                for (var p in filterData) {
                    if (objc[p] !== filterData[p]) {
                        found = false
                        break
                    }
                }
                console.log("found: " + found)
                console.log(JSON.stringify(filterData))
                console.log(JSON.stringify(compareObjc))
                if (found) {
                    console.log("found!")
                    buscaModel.append(objc)
                }
            }
           if (!buscaModel.count)
                return
           toolBarState = "cancel"
           listViewModel.clear()
           for (i = 0; i < buscaModel.count; ++i)
                listViewModel.append(buscaModel.get(i))
        }
    }

    Connections {
        target: window
        enabled: isActivePage
        onEventNotify: {
            if (eventName === "filter") {
                console.log("abrir dialogo!")
                filterDialog.open()
            }
            if (eventName === Settings.events.cancel) {
                listViewModel.clear()
                buscaModel.clear()
                for (var i = 0; i < originalModel.count; ++i)
                    listViewModel.append(originalModel.get(i))
            }
        }
    }

    Connections {
        target: requestHttp
        onFinished: {
            if (statusCode != 200)
                return
            objects = response
            for (var i = 0; i < response.length; ++i)
                listViewModel.append(objects[i])
        }
    }

    Component {
        id: pageDelegate

        ListItem {
            primaryIconName: objeto_id.tipoObjeto_id.icone
            width: parent.width; height: 60
            primaryLabelText: objeto_id.nome
            secondaryLabelText: objects[index].devolucao !== null  ? "Devolvido em " + Qt.formatDateTime(objects[index].devolucao, "dd/MM/yyyy HH:mm") : "Não foi devolvido ainda"
            showSeparator: true
            onClicked: showDetail(index)
        }
    }
}
