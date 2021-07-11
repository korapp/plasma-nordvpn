function parseStdoutList(stdout) {
    const text = splitOutputs(stdout).rawValue;
    return text && text.trim().split(/[-,\s+]/).filter(Boolean);
}

// split lines into object
function parseStdoutProperties(text) {
    const lines = text && text.split('\n');
    const entries = lines.map(l => l.split(':').map(e => e.trim()));
    return fromEntries(entries);
}

// trim white spaces and progress 'animation' characters: \|/-
function cleanStdout(text) {
    return text && text.trim().replace(/^[|\/\\-\s]+/, '');
}

// split raw NordVPN response to actual response and side message
function splitOutputs(stdout) {
    const outputs = stdout && stdout.split(/^-\s*/gm);
    if (outputs.length > 1) {
        return {
            message: outputs[1],
            rawValue: outputs[2]
        }
    }
    return {
        message: '',
        rawValue: outputs[0]
    }
}

function prettyName(text) {
    return text && text.replace(/_/g, ' ');
}

// polyfill for Object.fromEntries
function fromEntries(entries) {
    return entries.reduce((obj, prop) => (obj[prop[0]] = prop[1], obj), {});
}

function mapStringsToModelObjects(strings, mergeWith) {
    return Array.from(strings).map(item => (Object.assign(stringToModel(item), mergeWith)))
}

function stringToModel(item) {
    return { id: item, text: prettyName(item) }
}

function forEach(model, cb) {
    for (var i = 0; i < model.count; i ++) {
        cb(model.get(i), i);
    }
}

function createBreadcrumbs(array) {
    return array.filter(Boolean)
        .map(s => s.text)
        .join(' > ');
}
