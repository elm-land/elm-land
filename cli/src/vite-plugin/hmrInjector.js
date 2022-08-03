const injectElmHot = (compiledESM, dependencies) => `
${compiledESM}
/* This HMR code is heavily basing on elm-hot by Keith Lazuka which is published under the MIT License
 * https://github.com/klazuka/elm-hot
 * https://github.com/klazuka/elm-hot/blob/master/LICENSE.txt
*/
if (import.meta.hot) {
  let elmVersion
  if (typeof elm$core$Maybe$Just !== 'undefined') {
    elmVersion = '0.19.0'
  } else if (typeof $elm$core$Maybe$Just !== 'undefined') {
    elmVersion = '0.19.1'
  } else {
    throw new Error("Could not determine Elm version")
  }
  const elmSymbol = (symbol) => {
    try {
      switch (elmVersion) {
        case '0.19.0':
          return eval(symbol);
        case '0.19.1':
          return eval('$' + symbol);
        default:
          throw new Error('Cannot resolve ' + symbol + '. Elm version unknown!')
      }
    } catch (e) {
      if (e instanceof ReferenceError) {
        return undefined;
      } else {
        throw e;
      }
    }
  }
  const instances = import.meta.hot.data ? import.meta.hot.data.instances || {} : {}
  let uid = import.meta.hot.data ? import.meta.hot.data.uid || 0 : 0
  const cancellers = []
  let initializingInstance = null
  let swappingInstance = null
  import.meta.hot.accept()
  import.meta.hot.accept([
    "${dependencies.join('", "')}"
  ], () => { })
  import.meta.hot.dispose((data) => {
    data.instances = instances
    data.uid = uid
    _Scheduler_binding = () => _Scheduler_fail(new Error("[vite-plugin-elm] Inactive Elm instance."))
    if (cancellers.length) {
      try {
        cancellers.forEach((cancel) => { cancel() })
      } catch (e) {
      }
    }
  })
  const getId = () => ++uid
  const findPublicModules = (parent, path) => {
    let modules = []
    Object.keys(parent).forEach((key) => {
      const child = parent[key]
      const currentPath = path ? path + '.' + key : key
      if ('init' in child) {
        modules.push({ path: currentPath, module: child })
      } else {
        modules = [ ...modules, ...findPublicModules(child, currentPath) ]
      }
    })
    return modules
  }
  const registerInstance = (domNode, flags, path, portSubscribes, portSends) => {
    const id = getId()
    const instance = {
      id, path, domNode, flags, portSubscribes, portSends,
      lastState: null,
      initialState: null
    }
    return instances[id] = instance
  }
  const isFullscreenApp = () => typeof elmSymbol("elm$browser$Browser$application") !== 'undefined' || typeof elmSymbol("elm$browser$Browser$document") !== 'undefined'
  const wrapDomNode = (node) => {
    const dummyNode = document.createElement("div")
    dummyNode.setAttribute("data-elm-hot", "true")
    dummyNode.style.height = "inherit"
    const parentNode = node.parentNode
    parentNode.replaceChild(dummyNode, node)
    dummyNode.appendChild(node)
    return dummyNode
  }
  const wrapPublicModule = (path, module) => {
    const originalInit = module.init
    if (originalInit) {
      module.init = (args) => {
        let elm
        const portSubscribes = {}
        const portSends = {}
        let domNode = null
        let flags = undefined
        if (typeof args !== 'undefined') {
          domNode = args['node'] && !isFullscreenApp() ? wrapDomNode(args['node']) : document.body
          flags = args['flags']
        } else {
          domNode = document.body
        }
        initializingInstance = registerInstance(domNode, flags, path, portSubscribes, portSends)
        elm = originalInit(args)
        wrapPorts(elm, portSubscribes, portSends)
        initializingInstance = null
        return elm
      }
    } else {
    }
  }
  const swap = (Elm, instance) => {
    swappingInstance = instance
    const containerNode = instance.domNode
    while (containerNode.lastChild) {
      containerNode.removeChild(containerNode.lastChild)
    }
    const m = getAt(instance.path.split('.'), Elm)
    if (m) {
      const args = { flags: instance.flags }
      if (containerNode === document.body) {
        // fullscreen
      } else {
        const nodeForEmbed = document.createElement("div")
        containerNode.appendChild(nodeForEmbed)
        args.node = nodeForEmbed
      }
      const elm = m.init(args)
      Object.keys(instance.portSubscribes).forEach((portName) => {
        if (portName in elm.ports && 'subscribe' in elm.ports[portName]) {
          const handlers = instance.portSubscribes[portName]
          if (!handlers.length) return
          handlers.forEach(elm.ports[portName].subscribe)
        } else {
          delete instance.portSubscribes[portName]
        }
      })
      Object.keys(instance.portSends).forEach((portName) => {
        if (portName in elm.ports && 'send' in elm.ports[portName]) {
          instance.portSends[portName] = elm.ports[portName].send
        } else {
          delete instance.portSends[portName]
        }
      })
    } else {
    }
    swappingInstance = null
  }
  const wrapPorts = (elm, portSubscribes, portSends) => {
    const portNames = Object.keys(elm.ports || {})
    if (portNames.length) {
      portNames
        .filter(name => "subscribe" in elm.ports[name])
        .forEach((portName) => {
          const port = elm.ports[portName]
          const subscribe = port.subscribe
          const unsubscribe = port.unsubscribe
          elm.ports[portName] = Object.assign(port, {
            subscribe: (handler) => {
              if (!portSubscribes[portName]) {
                portSubscribes[portName] = [handler]
              } else {
                portSubscribes[portName].push(handler)
              }
              return subscribe.call(port, handler)
            },
            unsubscribe: (handler) => {
              const list = portSubscribes[portName]
              if (list && list.indexOf(handler) !== -1) {
                list.splice(list.lastIndexOf(handler), 1)
              }
              return unsubscribe.call(port, handler)
            }
          })
        })
    portNames
      .filter(name => "send" in elm.ports[name])
      .forEach((portName) => {
        const port = elm.ports[portName]
        portSends[portName] = port.send
        elm.ports[portName] = Object.assign(port, {
          send: (val) => portSends[portName].call(port, val)
        })
      })
    }
    return portSubscribes
  }
  const isDebuggerModel = (model) => model && (model.hasOwnProperty("expando") || model.hasOwnProperty("expandoModel")) && model.hasOwnProperty("state")
  const findNavKey = (rootModel) => {
    const queue = []
    if (isDebuggerModel(rootModel)) {
      queue.push({ value: rootModel['state'], keypath: ['state'] })
    } else {
      queue.push({ value: rootModel, keypath: [] })
    }
    while (queue.length !== 0) {
      const item = queue.shift()
      if (typeof item.value === "undefined" || item.value === null) continue
      if (item.value.hasOwnProperty("elm-hot-nav-key")) return item
      if (typeof item.value !== "object") continue
      for (const propName in item.value) {
        if (!item.value.hasOwnProperty(propName)) continue
        const newKeypath = item.keypath.slice()
        newKeypath.push(propName)
        queue.push({ value: item.value[propName], keypath: newKeypath })
      }
    }
    return null
  }
  const getAt = (keyPath, obj) => keyPath.reduce((xs, x) => (xs && xs[x]) ? xs[x] : null, obj)
  const removeNavKeyListeners = (navKey) => {
    window.removeEventListener("popstate", navKey.value)
    window.navigator.userAgent.indexOf("Trident") < 0 || window.removeEventListener("hashchange", navKey.value)
  }
  const initialize = _Platform_initialize
  _Platform_initialize = (flagDecoder, args, init, update, subscriptions, stepperBuilder) => {
    const instance = initializingInstance || swappingInstance
    let tryFirstRender = !!swappingInstance
    const hookedInit = (args) => {
      const initialStateTuple = init(args)
      if (swappingInstance) {
        let oldModel = swappingInstance.lastState
        const newModel = initialStateTuple.a
        if (JSON.stringify(newModel.state?.a ? newModel.state.a : newModel) !== swappingInstance.initialState) {
          import.meta.hot.invalidate()
        }
        if (typeof elmSymbol("elm$browser$Browser$application") !== "undefined" && typeof elmSymbol("elm$browser$Browser$Navigation") !== "undefined") {
          const oldKeyLoc = findNavKey(oldModel)
          const newKeyLoc = findNavKey(newModel)
          let error = null
          if (newKeyLoc === null) {
            error = "could not find Browser.Navigation.Key in the new app model"
          } else if (oldKeyLoc === null) {
            error = "could not find Browser.Navigation.Key in the old app model"
          } else if (newKeyLoc.keypath.toString() !== oldKeyLoc.keypath.toString()) {
            error = "the location of the Browser.Navigation.Key in the model has changed.";
          } else {
            removeNavKeyListeners(oldKeyLoc.value)
            const parentKeyPath = oldKeyLoc.keypath.slice(0, -1)
            const lastSegment = oldKeyLoc.keypath.slice(-1)[0]
            const oldParent = getAt(parentKeyPath, oldModel)
            oldParent[lastSegment] = newKeyLoc.value
          }
          if (error !== null) {
            oldModel = newModel
          }
        }
        initialStateTuple.a = oldModel
        initialStateTuple.b = elmSymbol("elm$core$Platform$Cmd$none")
      } else {
        initializingInstance.lastState = initialStateTuple.a
        initializingInstance.initialState = JSON.stringify(initialStateTuple.a.state?.a ? initialStateTuple.a.state.a : initialStateTuple.a)
      }
      return initialStateTuple
    }
    const hookedStepperBuilder = (sendToApp, model) => {
      let result
      if (tryFirstRender) {
        tryFirstRender = false
        try {
          result = stepperBuilder(sendToApp, model)
        } catch (e) {
          throw new Error("[vite-plugin-elm] Hot-swapping " + instance.path + " is not possible, please reload page. Error: " + e.message)
        }
      } else {
        result = stepperBuilder(sendToApp, model)
      }
      return (nextModel, isSync) => {
        if (instance) instance.lastState = nextModel
        return result(nextModel, isSync)
      }
    }
    return initialize(flagDecoder, args, hookedInit, update, subscriptions, hookedStepperBuilder)
  }
  const originalBinding = _Scheduler_binding
  _Scheduler_binding = (originalCallback) => originalBinding(function () {
    const cancel = originalCallback.apply(this, arguments)
    if (cancel) {
      cancellers.push(cancel)
      return () => {
        cancellers.splice(cancellers.indexOf(cancel), 1)
        return cancel()
      }
    }
  })
  const swapInstances = (Elm) => {
    const removedInstances = []
    Object.entries(instances).forEach(([id, instance]) => {
      if (instance.domNode.parentNode) {
        swap(Elm, instance)
      } else {
        removedInstances.push(id)
      }
    })
    removedInstances.forEach((id) => {
      delete instance[id]
    })
    findPublicModules(Elm).forEach((m) => {
      wrapPublicModule(m.path, m.module)
    })
  }
  swapInstances(Elm)
}
`

// https://github.com/klazuka/elm-hot/blob/master/src/inject.js#L16
const hotFixForElmHotNavKey = (esm) => {
  const hotFixForMissingKey = 'function() { key.a(onUrlChange(_Browser_getUrl())); };'
  return esm.includes('elm$browser$Browser$application')
    ? esm.replace(hotFixForMissingKey, `${hotFixForMissingKey}\n\tkey['elm-hot-nav-key'] = true;\n`)
    : esm
}

const injectHMR = (compiledESM, dependencies) =>
  injectElmHot(hotFixForElmHotNavKey(compiledESM), dependencies)

module.exports = {
  injectHMR
}