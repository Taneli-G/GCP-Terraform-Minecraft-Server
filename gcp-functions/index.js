/**
 * Very barebones startup/shutdown functions. To be improved.
 */

const functions = require('@google-cloud/functions-framework');
const {InstancesClient} = require('@google-cloud/compute').v1;

/**
*  Name of the instance resource to start.
*/
const instance = 'minecraft-server'
/**
*  Project ID for this request.
*/
const project = 'moose-hunters-mineservu'
/**
*  The name of the zone for this request.
*/
const zone = 'europe-north1-a'
    

functions.http('startInstance', (req, res) => {
    // Instantiates a client
    const computeClient = new InstancesClient();

    async function callStart() {
        // Construct request
        const request = {
        instance,
        project,
        zone,
        };

        // Run request
        const response = await computeClient.start(request);
        console.log(response);
    }

    callStart();

    res.status(200).send('Successfully started instance');
})

functions.http('stopInstance', (req, res) => {
    // Instantiates a client
    const computeClient = new InstancesClient();
    
    async function callStop() {
        // Construct request
        const request = {
          instance,
          project,
          zone,
        };
    
        // Run request
        const response = await computeClient.stop(request);
        console.log(response);
    }
    
    callStop();

    res.status(200).send('Successfully stopped instance');
})

