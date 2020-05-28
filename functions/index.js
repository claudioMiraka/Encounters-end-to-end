const functions = require('firebase-functions');
const admin = require('firebase-admin')

admin.initializeApp()

exports.addChattingUser= functions.firestore
	.document('chats/{chats}')
	.onCreate((snap, context)=>{
		const doc= snap.data();
		const creatorDisplayName = doc.creatorDisplayName;
		const creatorId= doc.creatorId;
		const peerId= doc.peerId;
		console.log(peerId);
		var payload = {
			notification: {
				title: `${creatorDisplayName} accepted your request`,
				body: `Start chatting now!`,
				badge: '1',
				sound: 'default'
			}
		}
		notify(payload,peerId);
		const userRef = admin.firestore().collection('users').doc(peerId);
		return admin.firestore().runTransaction(async transaction => {
			return transaction.update(userRef,{
				chats: admin.firestore.FieldValue.arrayUnion(creatorId)
				}
			);
		});

	});
	
exports.sendChatRequestNotification = functions.firestore
  .document('users/{userId}/chatRequests/{requestedId}')
  .onCreate((snap, context) => {
	  const doc= snap.data;
	  const name= doc.displayName;
	  const payload = {
			notification: {
				title: `${name} has requested to chat with you`,
				body: `Accept the request and start chatting now`,
				badge: '1',
				sound: 'default'
			}
		}
		notify(payload, userId)
		return null
	}).catch(err => {
		console.log("Error: "+err);
	})
    return null
  });
	
exports.sendNewChatMessageNotification = functions.firestore
  .document('chats/{chatId}/messages/{messageId}')
  .onCreate((snap, context) => {

    const doc = snap.data()
	const senderId = doc.idFrom
	const receiverID = doc.idTo
	const content = doc.content

	admin.firestore().collection('users').doc(senderId).get()
	.then(document => {
		const senderName= document.data().displayName;
		const payload = {
			notification: {
				title: `${senderName}`,
				body: `New message`,
				badge: '1',
				sound: 'default'
			}
		}
		notify(payload, receiverID)
		return null
	}).catch(err => {
		console.log("Error: "+err);
	})
	
    return null
  })
	
function notify(payload,userId){
	//get user to send notification to 
	admin
	.firestore()
	.collection('users')
	.doc(userId)
	.get()
	.then(doc => {	
		
		//send notification
		admin
		.messaging()
        .sendToDevice(doc.data().deviceToken, payload)
		.then(response => {
			return null;
        })
        .catch(error => {
			console.log('Error sending message:', error)
        })
		return null
	}).catch(err => {
		console.log("Error: "+err);
	});
}