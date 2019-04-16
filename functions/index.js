const functions = require('firebase-functions');

const admin = require('firebase-admin');
admin.initializeApp(functions.config().firebase);

exports.observeComments = functions.database.ref('/comments/{postId}/{commentId}').onCreate((snapshot, context) => {
  var postId = context.params.postId;
  var commentId = context.params.commentId;

  return admin.database().ref('/comments/' + postId + '/' + commentId).once('value', snapshot => {
    var comment = snapshot.val();
    var commentUid = comment.uid;

    return admin.database().ref('/users/' + commentUid).once('value', snapshot => {
      var commentingUser = snapshot.val();
      var username = commentingUser.username;

      return admin.database().ref('/posts/' + postId).once('value', snapshot => {
        var post = snapshot.val();
        var postOwnerUid = post.ownerUid;

        return admin.database().ref('/users/' + postOwnerUid).once('value', snapshot => {
          var postOwner = snapshot.val();

          var payload = {
            notification: {
              body: username + ' commented on your post: ' + comment.commentText
            }
          };

          admin.messaging().sendToDevice(postOwner.fcmToken, payload)
            .then(function(response) {
              // Response is a message ID string.
              console.log('Successfully sent message:', response);
            })
            .catch(function(error) {
              console.log('Error sending message:', error);
            });
        })
      })
    })
  })
})

exports.observeLikes = functions.database.ref('/user-likes/{uid}/{postId}').onCreate((snapshot, context) => {
  var uid = context.params.uid;
  var postId = context.params.postId;

  return admin.database().ref('/users/' + uid).once('value', snapshot => {
    var userThatLikedPost = snapshot.val();

    return admin.database().ref('/posts/' + postId).once('value', snapshot => {
      var post = snapshot.val();

      return admin.database().ref('/users/' + post.ownerUid).once('value', snapshot => {
        var postOwner = snapshot.val();

        var payload = {
          notification: {
            body: userThatLikedPost.username + ' liked your post'
          }
        };

        admin.messaging().sendToDevice(postOwner.fcmToken, payload)
          .then(function(response) {
            // Response is a message ID string.
            console.log('Successfully sent message:', response);
          })
          .catch(function(error) {
            console.log('Error sending message:', error);
          });
      })
    })
  })
})

exports.observeFollow = functions.database.ref('/user-following/{uid}/{followedUid}').onCreate((snapshot, context) => {

  var uid = context.params.uid;
  var followedUid = context.params.followedUid;

  return admin.database().ref('/users/' + followedUid).once('value', snapshot => {
    var userThatWasFollowed = snapshot.val();

    return admin.database().ref('/users/' + uid).once('value', snapshot => {
      var userThatFollowed = snapshot.val();

      var payload = {
        notification: {
          title: 'You have a new follower!',
          body: userThatFollowed.username + ' started following you'
        }
      };

      admin.messaging().sendToDevice(userThatWasFollowed.fcmToken, payload)
        .then(function(response) {
          // Response is a message ID string.
          console.log('Successfully sent message:', response);
        })
        .catch(function(error) {
          console.log('Error sending message:', error);
        });
    })
  })
})

exports.observeMessages = functions.database.ref('/user-message-notifications/{uid}/{notificationId}').onCreate((snapshot, context) => {
    var uid = context.params.uid;
    var notificationId = context.params.notificationId;

    var message = snapshot.val();

    return admin.database().ref('/users/' + message.fromId).once('value', snapshot => {
        var messageSender = snapshot.val();

        return admin.database().ref('/users/' + message.toId).once('value', snapshot => {
            var messageRecipient = snapshot.val();

            var payload = {
              notification: {
                body: messageSender.username + ' sent you a message: ' + message.messageText
              }
            };

            admin.messaging().sendToDevice(messageRecipient.fcmToken, payload)
              .then(function(response) {
                // Response is a message ID string.
                console.log('Successfully sent message:', response);
              })
              .catch(function(error) {
                console.log('Error sending message:', error);
              });
        })
    })
})