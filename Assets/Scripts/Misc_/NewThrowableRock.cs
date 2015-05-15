﻿using UnityEngine;
using System.Collections;

public class NewThrowableRock : MonoBehaviour {

	public bool isSelected = false;
	public bool isGrowing = false;
	public bool inTheAir = false;
	[HideInInspector]
	public int selectionNumber = 0;
	
	public Vector3 normalScale;
	
	[HideInInspector]
	public bool homingAttackBool = false;
	[HideInInspector]
	public Transform aimHoming;
	[HideInInspector]
	public bool beingThrowned = false;
	[HideInInspector]
	public int throwedRockNumber = 0;
	[HideInInspector]
	public bool isThrowed = false;
	
	public float throwForce = 1000;
	
	public bool canExplode = false;
	public Vector3 posAtLaunch = Vector3.zero;
	public float maxTravelDistance = 15;
	public float DecelerationRate = 15;
	public float maxVelocityWhenDecelerating = 22;
	public float growingRate = .5f;
	
	[HideInInspector]
	public bool growingMyself = true;
	
	// Use this for initialization
	void Start () 
	{
	}
	
	// Update is called once per frame
	void Update () 
	{
		#region track distance travelled
		if (Vector3.SqrMagnitude(transform.position - posAtLaunch) > maxTravelDistance * maxTravelDistance && !isSelected && isThrowed)
		{
			rigidbody.useGravity = true;
			constantForce.force = Vector3.zero;
			
			if (Vector3.SqrMagnitude(rigidbody.velocity) > maxVelocityWhenDecelerating * maxVelocityWhenDecelerating)
			{
				rigidbody.drag = DecelerationRate;
			}
			else
				rigidbody.drag = 0;
			
			homingAttackBool = false;
		}
		#endregion
		
		if (homingAttackBool)
			homingAttack();
	}
	
	//With this method, we make sure that if the player throwed the rock toward an enemy, he can be almost sure he will hit it.
	void homingAttack ()
	{
		Debug.Log ("Homin' attack");
		if (aimHoming.GetComponent <BasicEnemy> ().canGetHit) 
		{
			Debug.Log ("Homin' attack, bitchiz");
			
			
			
			Vector3 throwDir = aimHoming.position - this.transform.position;
			throwDir.Normalize ();
			
			this.rigidbody.constraints = RigidbodyConstraints.None;
			
			constantForce.force = throwDir * throwForce;
		} 
		else
			homingAttackBool = false;
	}
	
	//To avoid the rock to be difficult to aim, we reactivate gravity only after the first hit, when it's not selected anymore.
	void OnCollisionEnter (Collision collider)
	{
		JustHitSomething();
	}
	
	void JustHitSomething ()
	{
		if (!isSelected) 
		{
			rigidbody.useGravity = true;
			constantForce.force = Vector3.zero;
			homingAttackBool = false;
			beingThrowned = false;
		}
	}
	
	void InstantGrow ()
	{
		growingMyself = false;
	}
	
}
