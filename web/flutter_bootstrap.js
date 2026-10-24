{{flutter_js}}
{{flutter_build_config}}

// Remove a tela de carregamento quando o app desenhar o primeiro quadro.
_flutter.loader.load({
  onEntrypointLoaded: async function (engineInitializer) {
    const appRunner = await engineInitializer.initializeEngine();
    await appRunner.runApp();
    document.getElementById('loading')?.remove();
  },
});
