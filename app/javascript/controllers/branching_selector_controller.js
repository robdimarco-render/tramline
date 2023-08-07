import {Controller} from "@hotwired/stimulus";

const STRATEGIES = {
  almost_trunk: "almost_trunk",
  release_backmerge: "release_backmerge",
  parallel_working: "parallel_working"
}
export default class extends Controller {
  static targets = ["branchingStrategy", "almostTrunk", "releaseBackMerge", "parallelBranches", "schedule"]
  static outlets = ["domain--release-schedule-help"]

  initialize() {
    this.showCorrectInputs()
  }

  change() {
    this.showCorrectInputs()
  }

  showCorrectInputs() {
    this.__resetFields()
    const selectedBranchingStrategy = this.branchingStrategyTarget.value

    if (selectedBranchingStrategy === STRATEGIES.almost_trunk) {
      this.almostTrunkTarget.hidden = false
      this.__showSchedule()
    } else if (selectedBranchingStrategy === STRATEGIES.release_backmerge) {
      this.releaseBackMergeTarget.hidden = false
      this.__hideSchedule()
    } else if (selectedBranchingStrategy === STRATEGIES.parallel_working) {
      this.parallelBranchesTarget.hidden = false
      this.__hideSchedule()
    }
  }

  __resetFields() {
    this.almostTrunkTarget.hidden = true
    this.releaseBackMergeTarget.hidden = true
    this.parallelBranchesTarget.hidden = true
  }

  __hideSchedule() {
    this.scheduleTarget.hidden = true

    if (this.hasDomainReleaseScheduleHelpOutlet) {
      this.domainReleaseScheduleHelpOutlet.resetSchedule()
    }
  }

  __showSchedule() {
    this.scheduleTarget.hidden = false
  }
}
