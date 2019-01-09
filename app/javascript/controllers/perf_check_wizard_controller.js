import { Controller } from "stimulus"

export default class extends Controller {
  static targets = [ "numberOfRuns", "branchName", "finalCommand", "onlyBenchBranch", "runMigrations", "verifyNoDiff", "runAsUserSelect", "runAsUserEmail"]

  connect() {
    this.numberOfRunsTarget.value = '20'
    this.branchNameTarget.value = 'master'
    this.setFinalCommand()
  }

  // Figure out how to move over to dynamic targets?
  addUrl (event) {
    $('#urls-to-benchmark').append('<li><input type="text" name="url" class="text-field url-to-benchmark" placeholder="/path/to/benchmark" data-action="keyup->perf-check-wizard#setFinalCommand change->perf-check-wizard#setFinalCommand"></li>')
    event.preventDefault()
    return false;
  }

  getUrlValues() {
    var urls = [];
    $.each($('.url-to-benchmark'), function( index, item ) {
      var url = $(item).val()
      if(url != ''){
        urls.push($(item).val());        
      }
    });
    return urls.join(' ');
  }

  runAsUserCmd() {
    var user_email_value = this.runAsUserEmailTarget.value;

    if(user_email_value != '') {
      return user_email_value;
    } else {
      var user = this.runAsUserSelectTarget.value;
      if(user != '') {
        return "--" + user;
      }      
    }
  }

  generateArgumentString(target, prefix) {
    if(target.value != undefined && target.value != ''){
      return prefix + ' ' + target.value;
    } else {
      return '';
    }
  }

  generateArgumentBoolean(target, cmd) {
    if(target.checked){
      return cmd;
    }
  }

  setFinalCommand() {
    var numberOfRunsCmd = this.generateArgumentString(this.numberOfRunsTarget, '-n');
    var branchNameCmd = this.generateArgumentString(this.branchNameTarget, '-r');
    var onlyBenchBranchCmd = this.generateArgumentBoolean(this.onlyBenchBranchTarget, '--branch');
    var runMigrationsCmd = this.generateArgumentBoolean(this.runMigrationsTarget, '--run-migrations');
    var verifyNoDiffCmd = this.generateArgumentBoolean(this.verifyNoDiffTarget, '--verify-no-diff');

    var runAsUserCmd = this.runAsUserCmd()
    var urlCmd = this.getUrlValues();

    this.finalCommandTarget.value = [runAsUserCmd, numberOfRunsCmd, branchNameCmd, onlyBenchBranchCmd, runMigrationsCmd, verifyNoDiffCmd, urlCmd].join(' ');
  }
}
