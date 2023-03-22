const prompts = require('prompts');

async function getUserInputFromDropdown(msgData, choiceData) {
    const items = choiceData;
    const selectedIndex = 0;

    const response = await prompts({
        type: 'select',
        name: 'value',
        message: msgData,
        choices: items.map((item, index) => ({ title: item, value: index })),
        initial: selectedIndex
    });

    return response.value;
}

async function getUserInputText(msgData) {
    const response = await prompts({
        type: 'text',
        name: 'value',
        message: msgData
        });
    
        return response.value;
    }

async function getUserInputFloat(msgData) {
    const response = await prompts({
        type: 'number',
        name: 'value',
        message: msgData,
        validate: value => {
        if (isNaN(value) || !Number.isFinite(value)) {
            return 'Please enter a valid floating point number';
        }
        return true;
        },
        float: true
    });
    
    return response.value;
    }

async function getUserInputInt(msgData) {
    const response = await prompts({
        type: 'number',
        name: 'value',
        message: msgData,
        validate: value => {
        if (!Number.isInteger(value)) {
            return 'Please enter a valid integer';
        }
        return true;
        }
    });
    
    return response.value;
    }


module.exports = {
    getUserInputFromDropdown,
    getUserInputText,
    getUserInputFloat,
    getUserInputInt,
};