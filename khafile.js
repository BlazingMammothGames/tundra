let project = new Project('tundra');

project.addSources('Sources');
project.addShaders('Shaders/**');

project.addLibrary('glm');
project.addLibrary('gltf');
project.addLibrary('zui');

project.addAssets('Assets/**');

project.addParameter('-debug');

// HTML target
project.windowOptions.width = '100%';
project.windowOptions.height = '100%';

resolve(project);

