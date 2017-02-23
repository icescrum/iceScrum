angular.module('angular.qserial', [])
    .config(['$provide',function ($provide) {

    $provide.decorator("$q", ["$delegate", function ($delegate) {
        //Helper method copied from q.js.
        var isPromiseLike = function (obj) { return obj && angular.isFunction(obj.then); };
        /*
         * @description Execute a collection of tasks serially.  A task is a function that returns a promise
         *
         * @param {Array.<Function>|Object.<Function>} tasks An array or hash of tasks.  A tasks is a function
         *   that returns a promise.  You can also provide a collection of objects with a success tasks, failure task, and/or notify function
         * @returns {Promise} Returns a single promise that will be resolved or rejected when the last task
         *   has been resolved or rejected.
         */
        function serial(tasks) {
            //Fake a "previous task" for our initial iteration
            var prevPromise;
            var error = new Error();
            angular.forEach(tasks, function (task, key) {
                var success = task.success || task;
                var fail = task.fail;
                var notify = task.notify;
                var nextPromise;

                //First task
                if (!prevPromise) {
                    nextPromise = success();
                    if (!isPromiseLike(nextPromise)) {
                        error.message = "Task " + key + " did not return a promise.";
                        throw error;
                    }
                } else {
                    //Wait until the previous promise has resolved or rejected to execute the next task
                    nextPromise = prevPromise.then(
                        /*success*/function (data) {
                            if (!success) { return data; }
                            var ret = success(data);
                            if (!isPromiseLike(ret)) {
                                error.message = "Task " + key + " did not return a promise.";
                                throw error;
                            }
                            return ret;
                        },
                        /*failure*/function (reason) {
                            if (!fail) { return $delegate.reject(reason); }
                            var ret = fail(reason);
                            if (!isPromiseLike(ret)) {
                                error.message = "Fail for task " + key + " did not return a promise.";
                                throw error;
                            }
                            return ret;
                        },
                        notify);
                }
                prevPromise = nextPromise;
            });

            return prevPromise || $delegate.when();
        }

        $delegate.serial = serial;
        return $delegate;
    }]);

}]);